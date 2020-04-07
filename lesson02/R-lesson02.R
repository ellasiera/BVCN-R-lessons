# We will work with the iris database, which comes with R. This is how you load it:
data("iris")

# Get a general idea of the iris table
str(iris)
head(iris)
nrow(iris)
ncol(iris)
colnames(iris)
rownames(iris)
# You can change a columns name like this
colnames(iris)[2] <- "Sep.Wid"
colnames(iris)[2] <- "Sepal.Width"

# Transposing a table
t(iris)

# Sorting the table
iris[order(iris$Petal.Length, decreasing=TRUE),]
# Sorting by multiple columns
iris[order(iris$Species, iris$Petal.Length),]
# Sorting by multiple columns - species and decreasing petal length
iris[order(iris$Species, -iris$Petal.Length),]

# Filtering by column value: I have to exclude the last column from the analysis 
# because it's not numeric. See what happens when you don't exclude it!
iris[iris$Sepal.Length>7,]
iris[iris$Species=="setosa",]

# Summing by row/column
colSums(iris[,-ncol(iris)])
rowSums(iris[,-ncol(iris)])

# Converting to relative abundance
# This isn't meaningful when using the iris database, but pretend it was a counts table
# For example this would be useful for amplicons
# There are two ways to do this. One involves looping through all the rows, 
# and the other uses a very important function in R called "apply".

# Let's start with a loop
# First let's save the column sums into a vector named vec
vec <- colSums(iris[,-ncol(iris)])
# We'll manipulate a new table named iris2 (you could also manipulate your original table)
# Here we are going row by row and dividing the cells in that row by the vector of column sums
# R will divide the first cell in the row by the first cell in the vector, 
# the second by the second etc.
iris2 <- iris
for (r in 1:nrow(iris2)) {
  iris2[r,-ncol(iris2)] <- iris2[r,-ncol(iris2)]/vec
}
head(iris2)

# Now let's do the same with apply
# Define a function that divides a row by the vector of column sums (vec)
divByColsum <- function(x) {x/vec}
iris2 <- apply(iris[,-ncol(iris)], 1, divByColsum)
head(iris2)
# Notice that apply transposes the table, so let's run it again and also transpose the output
iris2 <- t(apply(iris[,-ncol(iris)], 1, divByColsum))
str(iris2)
# Iris2 is now a list, which is a different data type in R. We want a data frame:
iris2 <- as.data.frame(t(apply(iris[,-ncol(iris)], 1, divByColsum)))
str(iris2)

# Now iris2 doesn't have the Species column.
# We can use the function merge to merge two table by a column that exists in both of them that has unique IDs
# We don't have a variable like this here, but we haven't changed the order of rows, 
# so we can use row names as an ID variable
iris3 <- merge(iris2, iris, by="row.names")
head(iris3)
# Oops, now we have both counts and relative abundance in the same table as well as an additional
# variable names Row.names.
# Let's try again:
iris3 <- merge(iris2, iris$Species, by="row.names")
head(iris3)
# Throwing out the first column
iris3 <- iris3[,-1]
head(iris3)
# Sadly row names is not a numeric variable, but a string. That's why iris3 isn't in the same order as iris.
# What if we actually had a common column between the tables we're merging?
iris4 <- iris[,c(1:3)]
iris4$ID <- row.names(iris)
iris5 <- iris[,c(4,5)]
iris5$ID <- row.names(iris)
# Now we have 2 tables where column 1 is common between them
iris6 <- merge(iris4, iris5, by="ID")

# What if we the column we're using to merge has a different name in each table?
iris5 <- iris[,c(4,5)]
iris5$George <- row.names(iris)
iris6 <- merge(iris4, iris5, by.x="ID", by.y="George")
