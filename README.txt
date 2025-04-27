En esta sección se encuentra el caso práctico realizado y un manual de usuario para poder replicar el mismo, en este caso el caso práctico ha sido el crear y desplegar un contrato de votaciones del cual se detallarán las características abajo:
Las funcionalidades del contrato son las siguientes:

Función	Descripción	Parámetros de entrada	Salida
createElection	Crea una nueva elección.	name (nombre de la elección), options (array de opciones), durationInSeconds (duración en segundos), isAnonymous (bool si los votos son anónimos).	No devuelve nada, emite evento ElectionCreated.
vote	Vota en una elección activa.	electionId, option (nombre de la opción a votar).	No devuelve nada, emite evento Voted.
closeElection	Cierra manualmente una elección activa (solo el creador).	electionId	No devuelve nada, emite evento ElectionClosed.
deleteElection	Elimina una elección si no tiene votos (solo el creador).	electionId	No devuelve nada, emite evento ElectionDeleted.
getResults	Muestra los votos por opción.	electionId	Devuelve: (string [] options, uint256[] votos).
getWinners	Obtiene la(s) opción(es) ganadora(s).	electionId	Devuelve: string[] winners.
hasVoted	Consulta si una dirección ya votó.	electionId, address (votante).	Devuelve: bool.
getElectionInfo	Información general de una elección.	electionId	Devuelve: (name, options, active, creator, endTime, isAnonymous, totalVotes).
getActiveElections	Lista todas las elecciones activas.	Ninguno	Devuelve: uint256[] (Id de elecciones activas).
getInactiveElections	Lista elecciones inactivas o finalizadas.	Ninguno	Devuelve: uint256[].
changeElectionName	Cambiar el nombre de una elección sin votos.	electionId, méname.	No devuelve nada.
changeOptionName	Cambiar el nombre de una opción (si aún no hay votos).	electionId, índex (índice de opción), méname.	No devuelve nada.
Tabla 1: Funcionalidades del contrato

Todas estas funciones tienen en cuenta diversas reglas para que se mantenga un orden:
•	Solo el creador de una elección puede cerrarla, eliminarla o editarla.
•	No se pueden eliminar o editar elecciones que ya tengan algún voto
•	Si la elección es anónima los eventos de votación ocultan quien ha votado.
Los eventos registran información en los logs de la blockchain cuando sucede algo importante. Gastan menos gas que almacenar datos en variables y no afectan el estado del contrato. A continuación, se encuentran los eventos disponibles son:
•	ElectionCreated cuando se crea una elección
•	Voted al emitirse un voto, ya sea anónimo o no
•	ElectionClosed cuando se cierra una elección manualmente
•	ElectionDeleted al eliminar una elección sin votos
A continuación, se relata cómo se puede replicar el proceso realizado para que pueda desplegar el contrato:
1.	Descargar el archivo .sol del repositorio de GitHub dentro de la carpeta contractas https://github.com/JuanAntonioMorenoMoguel/CBD 
2.	En la página web de Remix (https://remix.ethereum.org/ ). En la sección de explorador de archivos presionar sobre abrir archivo del sistema de archivos y subir el archivo .sol
3.	Ir a la sección de solidity compiler y pulsar en Compile voting.sol para asegurar que todo carga correctamente
4.	Para desplegar, ir a la sección Deploy & Run y pulsar sobre el botón Deploy, más abajo en la sección de contratos desplegados deberá de salir todo lo referente al contrato y podrá comenzar a probarlo
Por último, se especifican una serie de pasos a seguir para comprobar que el contrato funciona correctamente:
1.	Crear una elección con nombre “Mejor fruta”, opciones: [“Plátano”,” Naranja”,” Tomate”], duración en segundos 600 (10 minutos) y no es anónima.
2.	Obtener los datos de una elección, en este caso introducir el id 1.
3.	Votar con la función Vote con el id 1 y la opción “Naranja”.
4.	Comprobar que haya votado introduciendo el id 1 y su dirección de cuenta actual.
5.	Ver los resultados con el electionId 1.
6.	Llamar a getActiveElections para ver las elecciones activas (debería de salir solo una).
7.	Esperar a que pasen los 10 minutos y comprobar que ya no estará activa la elección con la misma función del paso 6
