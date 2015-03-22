require(plyr)

uci_hard_dir <- "UCI\ HAR\ Dataset"
feature_file <- paste(uci_hard_dir, "/features.txt", sep = "")
activity_labels_file <- paste(uci_hard_dir, "/activity_labels.txt", sep = "")
x_train_file <- paste(uci_hard_dir, "/train/X_train.txt", sep = "")
y_train_file <- paste(uci_hard_dir, "/train/y_train.txt", sep = "")
subject_train_file <- paste(uci_hard_dir, "/train/subject_train.txt", sep = "")
x_test_file  <- paste(uci_hard_dir, "/test/X_test.txt", sep = "")
y_test_file  <- paste(uci_hard_dir, "/test/y_test.txt", sep = "")
subject_test_file <- paste(uci_hard_dir, "/test/subject_test.txt", sep = "")

# Load raw data
features <- read.table(feature_file, colClasses = c("character"))
activity_labels <- read.table(activity_labels_file, col.names = c("ActivityId", "Activity"))
x_train <- read.table(x_train_file)
y_train <- read.table(y_train_file)
subject_train <- read.table(subject_train_file)
x_test <- read.table(x_test_file)
y_test <- read.table(y_test_file)
subject_test <- read.table(subject_test_file)


# Binding sensor data
training_sensor_data <- cbind(cbind(x_train, subject_train), y_train)
test_sensor_data <- cbind(cbind(x_test, subject_test), y_test)
sensor_data <- rbind(training_sensor_data, test_sensor_data)

sensor_header <- rbind(rbind(features, c(562, "Subject")), c(563, "ActivityId"))[,2]
names(sensor_data) <- sensor_header

sensor_data.mean <- sensor_data[,grepl("mean|std|Subject|ActivityId", names(sensor_data))]

sensor_data.mean <- join(sensor_data.mean, activity_labels, by = "ActivityId", match = "first")
sensor_data.mean <- sensor_data.mean[,-1]

# Remove the brackets in the headers.
names(sensor_data.mean) <- gsub('\\(|\\)',"",names(sensor_data.mean), perl = TRUE)
# Make syntactically valid names
names(sensor_data.mean) <- make.names(names(sensor_data.mean))
# Make clearer names
names(sensor_data.mean) <- gsub('Acc',"Acceleration",names(sensor_data.mean))
names(sensor_data.mean) <- gsub('GyroJerk',"AngularAcceleration",names(sensor_data.mean))
names(sensor_data.mean) <- gsub('Gyro',"AngularSpeed",names(sensor_data.mean))
names(sensor_data.mean) <- gsub('Mag',"Magnitude",names(sensor_data.mean))
names(sensor_data.mean) <- gsub('^t',"TimeDomain.",names(sensor_data.mean))
names(sensor_data.mean) <- gsub('^f',"FrequencyDomain.",names(sensor_data.mean))
names(sensor_data.mean) <- gsub('\\.mean',".Mean",names(sensor_data.mean))
names(sensor_data.mean) <- gsub('\\.std',".StandardDeviation",names(sensor_data.mean))
names(sensor_data.mean) <- gsub('Freq\\.',"Frequency.",names(sensor_data.mean))
names(sensor_data.mean) <- gsub('Freq$',"Frequency",names(sensor_data.mean))


sensor_avg_by_act_sub = ddply(sensor_data.mean, c("Subject","Activity"), numcolwise(mean))
write.table(sensor_avg_by_act_sub, file = "tidy_sensor_avg_by_act_sub.txt")
