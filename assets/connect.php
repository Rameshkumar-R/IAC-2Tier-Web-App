<?php
$servername = "endpointname";
$database = "dbname";
$username = "admin";
$password = "password";

// Create connection
$conn = new mysqli($servername, $username, $password);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
echo "Connected To MYSQL using username - $username password - $password hostname - $servername database $database  successfully";
?>