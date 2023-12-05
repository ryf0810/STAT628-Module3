library(gplots)
hotel_data <- read.csv("hotel_SB_county.csv")
filter_df1 <- hotel_data[,c("business_id","review_count","useful","stars_review","text")]
filter_df1$comment_length <- nchar(filter_df1$text)
correlation <- cor(filter_df1$comment_length, filter_df1$stars_review)
filter_df1$WordCount <- sapply(strsplit(filter_df1$text, "\\s+"), length)
filter_df1$CharCount <- nchar(filter_df1$text)
filter_df1$Ave <- filter_df1$CharCount / filter_df1$WordCount
cor_matrix <- cor(filter_df1[,c("stars_review","comment_length","Ave")])

write.csv(filter_df1,"EDA.csv")