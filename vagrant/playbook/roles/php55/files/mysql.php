<?php // check DB connection
try
{
    $pdo = new PDO('mysql:dbname=vagrant_example;host=localhost', 'rooot', '');
}
catch (PDOException $e)
{
    exit('DB Error.' . $e->getMessage());
}

$stmt = $pdo->query('select * from test;');
echo '<pre>';
while($row = $stmt->fetch(PDO::FETCH_ASSOC))
{
    var_dump($row);
}
echo '</pre>';
