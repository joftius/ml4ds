
library(ggplot2)
library(glmnet)
library(lars)
library(broom)
library(hexSticker)
#library(viridis)
library(latex2exp)
library(showtext)

theme_set(theme_minimal())


primary_color = "#2d708e"
secondary_color = "#230433"
link_color = "#55c667"
text_bold_color = '#f68f46'

font_add_google("Turret Road", "turret")
## Automatically use showtext to render text for future devices
showtext_auto()

data(diabetes)

x <- diabetes$x
y <- diabetes$y
lasso_fit <- glmnet(x, y)

coef_plot <- lasso_fit |>
  tidy() |>
  dplyr::filter(term != "(Intercept)",
                lambda > 1) |>
  ggplot() + 
  aes(x = lambda, y = estimate, group = term) +
  scale_x_sqrt() +
#  scale_color_viridis_d(option = "E", begin = .6, end = 0) +
  scale_alpha(range = c(1,0)) +
  #xlab(TeX("$\\lambda$")) +
  ylab("") + xlab("") + #xlim(c(-1,201)) +
  theme(legend.position = "none")  +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        plot.margin=unit(c(5,-5,5,0), "pt")) +
  geom_line(color = primary_color) +
  geom_hline(yintercept = 0, size = 1, color = primary_color) +
  #theme_void() +
  theme_transparent()


s <- sticker(coef_plot, package="ml4ds",
             p_y = 1.5, p_family = "turret", p_color = "#373737",
             p_size=10, s_x=.825, s_y=.75, s_width=1.2, s_height=1.1,
             h_fill = "#ffffff", #primary_color,
             #p_color = primary_color,
             h_color = "#440154", #secondary_color,
        filename="files/sticker.png")
plot(s)


