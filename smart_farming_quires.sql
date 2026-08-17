DROP DATABASE IF EXISTS smart_farming;
CREATE DATABASE smart_farming;
USE smart_farming;

-- Sensor readings table (Arduino)
CREATE TABLE sensor_readings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    temperature FLOAT,
    humiditay FLOAT,
    ph FLOAT,
    reading_time TIME,
    reading_date DATE
);

-- Weather data table 
CREATE TABLE weather_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    w_temperature FLOAT,
    w_humidity FLOAT,
    w_reading_time TIME,
    w_reading_date DATE
);

-- Table of ideal values for watercress
CREATE TABLE ideal_conditions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    parameter_name VARCHAR(50),
    min_value FLOAT,
    max_value FLOAT,
    optimal_value FLOAT
);

-- Adding ideal values
INSERT INTO ideal_conditions (parameter_name, min_value, max_value, optimal_value) VALUES 
('temperature', 15, 25, 20),
('humidity', 50, 70, 60),
('ph', 60, 75, 65);

-- View daily data
DROP VIEW IF EXISTS daily_readings;
CREATE VIEW daily_readings AS
SELECT 
    reading_date,
    reading_time,
    ROUND(AVG(temperature), 1) as avg_temperature,
    ROUND(AVG(humidity), 1) as avg_humidity,
    ROUND(AVG(ph), 1) as avg_ph
FROM sensor_readings
GROUP BY reading_date , reading_time;

-- comparison of readings with ideal values
CREATE VIEW conditions_analysis AS
SELECT 
    s.reading_time,
    s.temperature as actual_temp,
    s.humidity as actual_humidity,
    s.ph as actual_ph,
    i1.optimal_value as ideal_temp,
    i2.optimal_value as ideal_humidity,
    i3.optimal_value as ideal_ph
FROM sensor_readings s
CROSS JOIN ideal_conditions i1
CROSS JOIN ideal_conditions i2
CROSS JOIN ideal_conditions i3
WHERE i1.parameter_name = 'temperature'
AND i2.parameter_name = 'humidity'
AND i3.parameter_name = 'ph';

-- weather data integration with sensor readings
CREATE VIEW weather_analysis AS
SELECT 
    s.reading_date as reading_date,
    HOUR(s.reading_time) as reading_hour,
    s.temperature as greenhouse_temp,
    w.w_temperature as outside_temp,
    s.humidity as greenhouse_humidity,
    w.w_humidity as outside_humidity
FROM sensor_readings s
LEFT JOIN weather_data w 
    ON s.reading_date = w.w_reading_date
    AND HOUR(s.reading_time) = HOUR(w.w_reading_time);
