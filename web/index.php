<?php
$host = "db-server";
$user = "webapp_user";
$pass = "WebAppPass123!";
$db   = "laboratorio_db";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Error de conexión a la base de datos: " . $conn->connect_error);
}

$mensaje = "";

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $usuario_id = $_POST["usuario_id"];
    $maquina_id = $_POST["maquina_id"];

    $stmt = $conn->prepare("INSERT INTO sesiones (usuario_id, maquina_id, inicio) VALUES (?, ?, NOW())");
    $stmt->bind_param("ii", $usuario_id, $maquina_id);

    if ($stmt->execute()) {
        $mensaje = "Sesión cargada correctamente.";
    } else {
        $mensaje = "Error al cargar sesión: " . $stmt->error;
    }

    $stmt->close();
}

$usuarios = $conn->query("SELECT id, nombre FROM usuarios");
$maquinas = $conn->query("SELECT id, nombre, estado FROM maquinas");
$sesiones = $conn->query("
    SELECT 
        s.id,
        u.nombre AS usuario,
        m.nombre AS maquina,
        s.inicio,
        s.fin,
        s.duracion_minutos,
        s.costo
    FROM sesiones s
    JOIN usuarios u ON s.usuario_id = u.id
    JOIN maquinas m ON s.maquina_id = m.id
    ORDER BY s.id DESC
");
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Ciber - Gestión de Horas</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background: #e0e0e0; /* gris más marcado */
            color: #111;
        }

        h1, h2 {
            color: #222;
        }

        form, table {
            background: #f8f8f8; /* gris claro en vez de blanco puro */
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
        }

        select, button {
            padding: 8px;
            margin: 5px;
            background: #ddd;
            border: 1px solid #aaa;
        }

        table {
            border-collapse: collapse;
            width: 100%;
        }

        th, td {
            border: 1px solid #bbb;
            padding: 8px;
            text-align: left;
        }

        th {
            background: #dcdcdc;
        }

        .mensaje {
            color: green;
            font-weight: bold;
        }
    </style>
</head>
<body>

<h1>Cyber Dioses - Gestión de Horas</h1>

<?php if ($mensaje): ?>
    <p class="mensaje"><?php echo $mensaje; ?></p>
<?php endif; ?>

<h2>Cargar nueva sesión</h2>

<form method="POST">
    <label>Usuario:</label>
    <select name="usuario_id" required>
        <?php while ($u = $usuarios->fetch_assoc()): ?>
            <option value="<?php echo $u['id']; ?>">
                <?php echo $u['nombre']; ?>
            </option>
        <?php endwhile; ?>
    </select>

    <label>Máquina:</label>
    <select name="maquina_id" required>
        <?php while ($m = $maquinas->fetch_assoc()): ?>
            <option value="<?php echo $m['id']; ?>">
                <?php echo $m['nombre']; ?> - <?php echo $m['estado']; ?>
            </option>
        <?php endwhile; ?>
    </select>

    <button type="submit">Iniciar sesión</button>
</form>

<h2>Sesiones registradas</h2>

<table>
    <tr>
        <th>ID</th>
        <th>Usuario</th>
        <th>Máquina</th>
        <th>Inicio</th>
        <th>Fin</th>
        <th>Duración</th>
        <th>Costo</th>
    </tr>

    <?php while ($s = $sesiones->fetch_assoc()): ?>
        <tr>
            <td><?php echo $s['id']; ?></td>
            <td><?php echo $s['usuario']; ?></td>
            <td><?php echo $s['maquina']; ?></td>
            <td><?php echo $s['inicio']; ?></td>
            <td><?php echo $s['fin'] ?? '-'; ?></td>
            <td><?php echo $s['duracion_minutos'] ?? '-'; ?></td>
            <td><?php echo $s['costo'] ?? '-'; ?></td>
        </tr>
    <?php endwhile; ?>
</table>

</body>
</html>

<?php
$conn->close();
?>