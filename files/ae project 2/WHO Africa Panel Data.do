*cleaning data
drop region doctors life_exp60 age519thinness age519obesity hospitals une_infant une_ gni une_life une_infant une_poverty une_literacy une_school
encode country, generate(country_num)
gen log_pop = log(1+une_pop)
gen log_gni = log(1 + une_gni)
gen log_gni_cap= log(1+ gni_capita)

*defining panel data and running regression
xtset country_num year
xtreg life_expect adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water gni_capita gghed che_gdp une_pop une_hiv une_edu_spend i.year, fe
estimates store fixed
xtreg life_expect adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water gni_capita gghed che_gdp une_pop une_hiv une_edu_spend i.year, re
estimates store random
hausman fixed random, sigmamore
*sigmamore to ensure positive definiteness of (V_b-V_B)

*joint significant testing of year dummies
xtreg life_expect adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water gni_capita gghed che_gdp une_pop une_hiv une_edu_spend i.year, fe
testparm i.year

*running the same thing with log of the variables with large variations
xtreg life_expect adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water log_gni_cap gghed che_gdp log_pop une_hiv log_gni une_edu_spend i.year, fe
estimates store fixed
xtreg life_expect adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water log_gni_cap gghed che_gdp log_pop une_hiv log_gni une_edu_spend i.year, re
estimates store random
hausman fixed random, sigmamore

*OLS assumptions testing: correlation matrix
pwcorr adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water gni_capita gghed che_gdp une_pop une_hiv une_edu_spend, star(0.05) sig
graph matrix adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water gni_capita gghed che_gdp une_pop une_hiv une_edu_spend, half maxis(ylabel(none) xlabel(none))

*checking for heteroskedasiticy
xtreg life_expect adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water gni_capita gghed che_gdp une_pop une_hiv une_edu_spend i.year, fe
predict LE_predict
gen u_hat= life_expect-LE_predict
twoway (scatter LE_predict u_hat)
ssc install xttest3
xttest3
*both methods conclude that there is heteroskedasticity in the data

*regression results using robust standard errors
xtreg life_expect adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water gni_capita gghed che_gdp une_pop une_hiv une_edu_spend i.year, robust fe

*VIF test
vif, uncentered

*Test of normality
predict e
kdensity e, normal
*shapiro wilk test
swilk e

*trying transfomation of dependent variable to solve normality issue
gen sqrt_LE = sqrt( life_expect)
gen log_LE = log( life_expect)
gen inv_LE = 1/ life_expect
xtreg log_LE adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water gni_capita gghed che_gdp une_pop une_hiv une_edu_spend i.year, fe
predict e_of_logLE, e
swilk e_of_logLE
xttest3
xtreg inv_LE adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water gni_capita gghed che_gdp une_pop une_hiv une_edu_spend i.year, fe
predict e_of_invLE, e
swilk e_of_invLE
xtreg sqrt_LE adult_mortality infant_mort age14mort alcohol bmi hepatitis measles polio diphtheria basic_water gni_capita gghed che_gdp une_pop une_hiv une_edu_spend i.year, fe
predict e_of_sqrtLE, e
swilk e_of_sqrtLE
