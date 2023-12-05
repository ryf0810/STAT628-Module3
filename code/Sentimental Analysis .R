rm(list = ls())
#read data
hotel_data <- read.csv("hotel_SB_county.csv")
filter_df1 <- hotel_data[,c("business_id","review_count","useful","stars_review","text")]
filter_df <- filter_df[order(filter_df$business_id,decreasing = T),]
library(tm)
library(SnowballC)
#data cleaning
filter_df$text <- gsub("[^a-zA-Z]", " ", filter_df$text)
filter_df$text <- gsub("<.*?>", "", filter_df$text)
filter_df$text <- gsub("\\b[A-Za-z]\\b", "", filter_df$text)
filter_df$text <- tolower(filter_df$text)
filter_df$text <- gsub("\\d", "", filter_df$text)
filter_df$text <- strsplit(filter_df$text, "\\s+")
stop_words <- stopwords("en")
filter_df$text <- lapply(filter_df$text, function(x) x[!x %in% stop_words])
filter_df$text <- lapply(filter_df$text, function(x) wordStem(x, language = "en"))
#sentimental analysis
library(tidytext)
library(slam)
library(text)
library(tidyverse)
library(tm)
library(sentimentr)

corp <- Corpus(VectorSource(filter_df$text))
dtm <- DocumentTermMatrix(corp)
dtm_df <- as.data.frame(as.matrix(dtm))
sentiment_predictions <- sentiment(filter_df$text)
filter_df$sentiment <- sentiment_predictions$sentiment
filter_df$sentiment_label <- ifelse(filter_df$sentiment > 0, "positive", ifelse(filter_df$sentiment < 0, "negative", "neutral"))
extreme_positive <- filter_df[filter_df$sentiment_label == "positive", ]
extreme_negative <- filter_df[filter_df$sentiment_label == "negative", ]

#barplot
library(ggplot2)
ggplot(filter_df, aes(x =stars_review , fill = sentiment_label)) +
  geom_bar(position = "dodge") +
  labs(x = "Rating Stars") +
  theme_minimal()


write.csv(filter_df,"filter_df.csv")
write.csv(filter_df1,"filter_df1.csv")
