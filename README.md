# Fruit Consumption Analysis (Survey 2013)

This repository contains an analysis of factors predicting daily fruit consumption using data from a large 2013 health habits survey.

### **Objective**
To examine how fruit consumption is predicted by:
- Gender  
- General health  
- Body Mass Index (BMI)  
- Arthritis condition  
- Physical activity (active times per month)

### **Methods**
- A Poisson regression model was used because fruit consumption is a count variable.
- Predictors were centered where appropriate.
- Treatment coding was applied to categorical variables.
- We compared linear and Poisson models using AIC.

### **Key Findings (Lay Summary)**
- People who exercise more tend to eat slightly more fruit.
- Men eat less fruit than women (≈ 0.25 servings/day less).
- Worse self-reported health is associated with lower fruit consumption.
- BMI and arthritis status do not meaningfully predict fruit intake.
- The best-fitting model was a Poisson regression without interaction terms.

### **Repository Structure**
- `scripts/`: All R code  
- `data/`: Dataset used in the analysis  
- `figures/`: Plots generated during the analysis  
- `README.md`: Project overview  

### **How to Run**
Open `scripts/fruit_analysis.R` in RStudio and run the script.  
Figures will be saved automatically into the `figures/` folder (if you add `ggsave()` calls).

---

### **Author**
Sunny  

