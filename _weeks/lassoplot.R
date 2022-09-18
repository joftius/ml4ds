
```{r echo = FALSE}
library(gridExtra)
library(tidyverse)
library(broom)
library(glmnet)
theme_set(theme_minimal())
set.seed(19)
n <- 100
p <- 100
sparsity <- 9
epsilon <- rnorm(n)
x <- matrix(rnorm(n*p), nrow = n)
mu <- x %*% c(.3*(-1)^(0:(sparsity-1)), rep(0, p - sparsity))
y <- mu + epsilon
fit <- glmnet(x, y, nlambda = 200, alpha = .9, lambda.min.ratio = .005)
tidied <- tidy(fit) %>% 
  filter(term != "(Intercept)") %>%
  mutate(signal = term %in% paste0("V", 1:sparsity)) %>%
  group_by(term) %>% 
  mutate(first_step = sqrt(min(step))) %>%
  ungroup()

#ggplot(tidied, aes(step, estimate, group = term, linetype = signal, color = signal)) +
#  geom_line() +
#  scale_color_viridis_d()

#lassoplot %>% filter(term == "V1", step < 5)
lassoplot <- rbind(
  tidied %>% filter(first_step == sqrt(step)) %>%  mutate(estimate = estimate/10, step = step - 1),
  tidied
)

p1.coef <- ggplot(lassoplot, aes(step, estimate, group = term, linetype = signal, color = signal)) +
  #geom_hline(yintercept = 0, size = 1) +
  geom_line(aes(alpha = first_step)) +
  scale_linetype_manual(values = c("longdash", "solid")) +
  #scale_size_manual(values = c(.6,.8)) + 
  scale_color_viridis_d(option = "E", begin = .6, end = 0) +
  scale_alpha(range = c(1,0)) +
  xlab("model complexity") +
  ylab("") + xlim(c(-1,201)) +
  theme(legend.position = "none")  +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        plot.margin=unit(c(5,-5,5,0), "pt"))

cvfit <- cv.glmnet(x, y, nfolds = 5)
#plot(cvfit)

cvtidy <- tidy(cvfit) %>%
  filter(lambda > 0.004) %>%
  mutate(rightness = sqrt(pmax(0, nzero - sparsity)))

p2.cv <- ggplot(cvtidy, aes(lambda, estimate, ymin = conf.low,
                            ymax = conf.high, color = rightness,
                            alpha = rightness)) +
  scale_alpha(range = c(1,.4)) +
  scale_color_viridis_c(option = "E", begin = 0, end = .6) +
  geom_errorbar(alpha = .4) +
  geom_point() +
  scale_x_log10() +
  theme(legend.position = "none") +
  xlab("regularization") +
  ylab("") +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        plot.margin=unit(c(5,0,5,-5), "pt"))
```

```{r echo = FALSE, layout = "l-page", fig.height = 3, fig.width = 8.1}
grid.arrange(p1.coef, p2.cv, nrow = 1) 
```








```{r echo = FALSE}
library(gridExtra)
library(tidyverse)
library(broom)
library(glmnet)
library(gifski)
library(gganimate)
library(transformr)
library(magick)
theme_set(theme_minimal())
set.seed(19)
n <- 100
p <- 100
sparsity <- 9
epsilon <- rnorm(n)
x <- matrix(rnorm(n*p), nrow = n)
mu <- x %*% c(.3*(-1)^(0:(sparsity-1)), rep(0, p - sparsity))
y <- mu + epsilon
fit <- glmnet(x, y, nlambda = 200, alpha = .9, lambda.min.ratio = .005)
tidied <- tidy(fit) %>% 
  filter(term != "(Intercept)") %>%
  mutate(signal = term %in% paste0("V", 1:sparsity)) %>%
  group_by(term) %>% 
  mutate(first_step = sqrt(min(step))) %>%
  ungroup()

#ggplot(tidied, aes(step, estimate, group = term, linetype = signal, color = signal)) +
#  geom_line() +
#  scale_color_viridis_d()

#lassoplot %>% filter(term == "V1", step < 5)
lassoplot <- rbind(
  tidied %>% filter(first_step == sqrt(step)) %>%  mutate(estimate = estimate/10, step = step - 1),
  tidied
)
```


```{r}
p1.coef <- ggplot(lassoplot, aes(step, estimate, group = term, linetype = signal, color = signal)) +
  #geom_hline(yintercept = 0, size = 1) +
  geom_line(aes(alpha = first_step)) +
  scale_linetype_manual(values = c("longdash", "solid")) +
  #scale_size_manual(values = c(.6,.8)) + 
  scale_color_viridis_d(option = "E", begin = .6, end = 0) +
  scale_alpha(range = c(1,0)) +
  xlab("model complexity") +
  ylab("") + xlim(c(-1,201)) +
  theme(legend.position = "none")  +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        plot.margin=unit(c(0,0,0,0), "pt"))
p1.coef
```


```{r}
anim.path <- p1.coef + 
  theme(aspect.ratio = 1/2,
        text=element_text(size=18)) +
  geom_point() +
  transition_reveal(step)
a1 <- animate(anim.path, fps = 20, nframes = 300, height = 300, width = 600)
```



```{r}
cvfit <- cv.glmnet(x, y, nfolds = 5)
#plot(cvfit)

cvtidy <- tidy(cvfit) %>%
  filter(lambda > 0.004) %>%
  distinct(nzero, .keep_all = TRUE) %>%
  mutate(rightness = sqrt(pmax(0, nzero - sparsity)),
         nzero = as.double(nzero))

p2.cv <- ggplot(cvtidy, aes(1 + nzero, estimate, ymin = conf.low,
                            ymax = conf.high, color = rightness,
                            alpha = rightness)) +
  scale_alpha(range = c(1,.4)) +
  scale_color_viridis_c(option = "E", begin = 0, end = .6) +
  geom_errorbar(alpha = .4) +
  geom_line(size = .7) +
  geom_line(aes(1 + nzero, conf.low), alpha = .5) +
  geom_line(aes(1 + nzero, conf.high), alpha = .5) +
  #scale_x_log10() +
  theme(legend.position = "none") +
  xlab("regularization") +
  ylab("") +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        plot.margin=unit(c(-5,0,0,0), "pt"))
p2.cv
```

```{r}
anim.cv <- p2.cv + 
  theme(aspect.ratio = 1/2,
        text=element_text(size=18)) +
  geom_point(aes(color = rightness)) +
  transition_reveal(nzero)
a2 <- animate(anim.cv, fps = 20, nframes = 300, height = 300, width = 600)
```



```{r echo = FALSE, layout = "l-page", fig.height = 3, fig.width = 8.1}
a_mgif <- image_read(a1)
b_mgif <- image_read(a2)

new_gif <- image_append(c(a_mgif[1], b_mgif[1]), stack = TRUE)
for(i in 2:300){
  combined <- image_append(c(a_mgif[i], b_mgif[i]), stack = TRUE)
  new_gif <- c(new_gif, combined)
}

image_browse(new_gif)
```

