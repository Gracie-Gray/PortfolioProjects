# Markov Chain
install.packages("markovchain")
install.packages("heemod")

require(heemod)
library(markovchain)

# make labels

labels <- c("Floor Sitting", "Balcony Seats", "Ground Laying")

# make transition matrix

m <- matrix(c(0.2, 0.3, 0.5, 0.7, 0.1, 0.2, 0.1, 0.3, 0.6),
nrow = 3, byrow = T, dimname = list(labels, labels))

# create object

Swifties <- new("markovchain", states = labels, 
byrow = TRUE,
transitionMatrix = m,
name = "Movement")

# print object
Swifties

# run 5 cycles
Swifties^5

# find steady-state 
steadyStates(zoneSwifties)

#detach("package:datasets", unload = TRUE)