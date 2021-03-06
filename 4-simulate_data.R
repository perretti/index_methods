source("3-clean.R")
# Simulate data
set.seed(1234)

n_rep <- 1000

n_scenario <- 5
terminal_year <- max(df_rfssb$Year) + n_scenario
df_sims <-
  base::expand.grid(rep = 1:n_rep,
                    driver = c("f", 
                               "r"
                               ),
                    scenario = c("no change",
                                 "increasing slowly",
                                 "increasing rapidly",
                                 "decreasing slowly",
                                 "decreasing rapidly"
                                 )) %>%
  dplyr::group_by(rep, driver, scenario) %>%
  dplyr::do(
    run_sim(n_ages        = 10,
            n_surveys     = 3,
            sd_multiplier = 2.5,
            n_burn        = 100,
            n_sim         = length(df_r$year),
            n_scenario    = n_scenario,
            driver        = .$driver,
            scenario      = .$scenario,
            df_r          = df_r,
            df_f          = df_f,
            terminal_year = terminal_year,
            return_burn   = FALSE,
            cor_mat       = matrix(data = 0,
                                   nrow = 3,
                                   ncol = 3))
    )


# Compare CV of simulations to CV of real data
(cv_sim <-
  sd(c(df_sims$biomass_obs.survey1, 
       df_sims$biomass_obs.survey2, 
       df_sims$biomass_obs.survey3)) / 
  mean(c(df_sims$biomass_obs.survey1, 
         df_sims$biomass_obs.survey2, 
         df_sims$biomass_obs.survey3)))

(cv_real <- sd(df_real$biomass) / mean(df_real$biomass))

# Quick plot of survey observations
df2plot <- 
  df_sims %>%
  dplyr::ungroup() %>%
  dplyr::filter(driver == "f",
                rep == 1,
                scenario == "no change") %>%
  dplyr::select(year, biomass_obs.survey1,
                biomass_obs.survey2,
                biomass_obs.survey3) %>%
  tidyr::gather(variable, value, -year)

ggplot(df2plot, aes(x = year, y = value, 
                    color = variable, group = variable)) +
  geom_line()


