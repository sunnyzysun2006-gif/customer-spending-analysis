############################################################
# Fruit Consumption Analysis (Survey 2013)
# Author: Sunny
# Purpose: Predict fruit consumption from demographic and
#          health variables using Poisson regression.
############################################################

library(tidyverse)
library(performance)
library(sjPlot)
library(ggeffects)

# ============================================================
# 1. LOAD DATA
# ============================================================

data <- read.csv("survey2013.csv")

# Create a folder for saving plots
if (!dir.exists("figures")) {
  dir.create("figures")
}

# ============================================================
# 2. EXPLORING DATA 
# ============================================================

# ---------------------------
# Plot 1: Histogram of fruit
# ---------------------------
p_hist <- ggplot(data, aes(x = fruits)) +
  geom_histogram() +
  theme_classic(base_size = 20) +
  labs(x = "Daily Fruit Serving")

ggsave("figures/hist_fruit.png", p_hist, width = 7, height = 5, dpi = 300)

# ---------------------------
# Factor recoding
# ---------------------------
data$genhealth <- as.factor(data$genhealth)
data <- data %>% 
  mutate(genhealth = recode(genhealth,
                       "1" = "Excellent",
                       "2" = "Very Good",
                       "3" = "Good",
                       "4" = "Fair",
                       "5" = "Poor"),
    gender = recode(gender, "M" = "Male", "F" = "Female"))

# ---------------------------
# Plot 2: Boxplot by general health (genhealth)
# ---------------------------
p_box <- ggplot(data, aes(x = genhealth, y = fruits, fill = genhealth)) +
  geom_boxplot(alpha = .5) +
  facet_wrap(~gender, scales = "free") +
  theme_classic(16) + theme(legend.position = "none") +
  labs(x = "General Health", y = "Daily Fruit Servings")

ggsave("figures/boxplot_fruit_by_health_gender.png",
       p_box, width = 8, height = 6, dpi = 300)

# ============================================================
# 3. VARIABLE TRANSFORMATION (centering)
# ============================================================

data <- data %>% mutate(bmi_z = as.numeric(scale(bmi, scale = FALSE)),
  activetimes_z = as.numeric(scale(activetimes, scale = FALSE)),
  gender_c = if_else(gender == "Male", .5, -.5),
  arthritis_c = if_else(arthritis == "1", .5, -.5))

# ============================================================
# 4. MODELING
# ============================================================

# Linear Regression (not ideal)
fruit_m1 <- lm(fruits ~ bmi_z + activetimes_z + gender + arthritis + genhealth, data = data)

# Poisson GLM (better model)
fruit_m2 <- glm(fruits ~ bmi_z + activetimes_z + gender_c + arthritis_c + genhealth,
  data = data, family = "poisson")

# Model with interactions (not better)
fruit_m3 <- glm(fruits ~ bmi_z + activetimes_z + gender_c + arthritis_c + genhealth +
    gender_c * bmi_z + gender_c * activetimes_z,
  data = data, family = "poisson")

AIC(fruit_m1, fruit_m2, fruit_m3)
# fruit_m2 is the best fit as the AIC value is the smallest, consideration of interactions does not help.

check_model(fruit_m2)
# There appears to be an issue with the homogeneity of variances, but otherwise the model seems to fit the data well

# ============================================================
# 5. SAVE MODEL RESULT PLOTS
# ============================================================

# ---------------------------
# Plot 3: Effect of active times
# ---------------------------
p_act <- plot(ggeffect(fruit_m2, "activetimes_z")) +
  labs(x = "Number of active times last month", y = "Fruit consumption")

ggsave("figures/fruit_vs_activetimes.png",
       p_act, width = 7, height = 5, dpi = 300)

# ---------------------------
# Plot 4: Effect of gender
# ---------------------------
p_gender <- plot(ggeffect(fruit_m2, "gender_c")) +
  labs(x = "Gender", y = "Fruit consumption")

ggsave("figures/fruit_by_gender.png",
       p_gender, width = 7, height = 5, dpi = 300)

# ---------------------------
# Plot 5: Effect of general health
# ---------------------------
p_health <- plot(ggeffect(fruit_m2, "genhealth")) +
  labs(x = "General health", y = "Fruit consumption")

ggsave("figures/fruit_by_genhealth.png",
       p_health, width = 7, height = 5, dpi = 300)

# ---------------------------
# 7. report summary
# ---------------------------
cat("

Data were analysed using a general linear model with a Poisson distribution. 
The number of fruit servings eaten per day were predicted from participants' gender, BMI, general health, number of active times in the last month, and the presence of arthritis. 
BMI and number of active times were continuous predictors that were centred at 0. 
Treatment contrast coding was applied to the remaining factor variables. 

This analysis examined what predicts people's daily fruit consumption.
Main findings:

1. People who exercise more tend to eat slightly more fruit.
2. Men eat less fruit than women (about 0.25 servings per day less).
3. People reporting worse general health eat less fruit than those with excellent health.
4. BMI and arthritis do not meaningfully predict fruit intake.

The best-fitting model was a Poisson regression without interactions.
")

# The model estimates are presented in Table 1 below:
tab_model(fruit_m1, transform = NULL, show.se = T, show.stat = T)

