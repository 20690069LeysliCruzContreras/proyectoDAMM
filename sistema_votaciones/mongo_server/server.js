const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

mongoose.connect('mongodb+srv://usley:140922USLEY@cluster0.domvtuq.mongodb.net/votaciones?retryWrites=true&w=majority', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(async () => {
  console.log('Conectado a MongoDB Atlas');
  try {
    // Actualiza todos los documentos de votación en la base de datos
    await Voting.updateMany(
      {}, // Sin filtro para seleccionar todos los documentos
      { $set: { "options.$[].votes": [] } } // Establece el campo votes en un arreglo vacío para cada opción
    );

    console.log('La estructura de votos se ha actualizado correctamente.');
  } catch (error) {
    console.error('Error al actualizar la estructura de votos:', error);
  }
}).catch((error) => {
  console.error('Error al conectar a MongoDB:', error);
});

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
});

const voteSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
});


const voteOptionSchema = new mongoose.Schema({
  text: String,
  //votes: { type: Number, default: 0 },
  //votes: [voteSchema], 
  votes: { type: [voteSchema], default: [] },
});

const votingSchema = new mongoose.Schema({
  title: String,
  options: [voteOptionSchema],
  startDate: Date,
  endDate: Date,
  results: Object, // Campo para almacenar los resultados de la votación
  creator: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // Campo para el creador de la votación
});


const User = mongoose.model('User', userSchema);
const Voting = mongoose.model('Voting', votingSchema);

//SI FUNCIONA
app.post('/register', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Verifica si el email ya existe en la base de datos
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).send('El correo electrónico ya está registrado');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({
      email,
      password: hashedPassword,
    });
    await user.save();
    res.status(201).send('Usuario registrado correctamente');
  } catch (error) {
    console.error('Error al registrar usuario:', error);
    res.status(500).send('Error al registrar usuario');
  }
});
//SI FUNCIONA
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (user && await bcrypt.compare(password, user.password)) {
      // Si el inicio de sesión es exitoso, puedes incluir el ID del usuario en la respuesta
      res.status(200).json({ message: 'Inicio de sesión exitoso', userId: user._id });
    } else {
      res.status(401).json({ error: 'Error al iniciar sesión, Credenciales inválidas' });
    }
  } catch (error) {
    console.error('Error en el inicio de sesión:', error);
    res.status(500).json({ error: 'Error en el inicio de sesión' });
  }
});


app.post('/create-voting', async (req, res) => {
  try {
    const voting = new Voting({
      title: req.body.title,
      options: req.body.options.map(option => ({ text: option, votes: [] })),
      startDate: new Date(req.body.startDate),
      endDate: new Date(req.body.endDate),
    });
    await voting.save();
    res.status(201).send('Votación creada correctamente');
  } catch (error) {
    console.error('Error al crear la votación:', error);
    res.status(500).send('Error al crear la votación');
  }
});



app.post('/vote', async (req, res) => {
  const { userId, votingId, optionText } = req.body;

  console.log('Datos recibidos en la solicitud de voto:');
  console.log(`UserId: ${userId}, VotingId: ${votingId}, OptionText: ${optionText}`);

  if (!mongoose.Types.ObjectId.isValid(userId)) {
    console.log('userId no es válido');
    return res.status(400).send('userId no es válido');
  }

  try {
    const voting = await Voting.findById(votingId);
    if (voting) {
      const option = voting.options.find(option => option.text === optionText);
      if (option) {
        console.log('Estado de los votos antes de agregar:', option.votes);
        option.votes.push({ userId: new mongoose.Types.ObjectId(userId) });
        console.log('Estado de los votos después de agregar:', option.votes);
        await voting.save();
        res.status(200).send('Voto registrado correctamente');
        console.log('Voto registrado correctamente');
      } else {
        console.log('Opción no encontrada');
        res.status(404).send('Opción no encontrada');
      }
    } else {
      console.log('Votación no encontrada');
      res.status(404).send('Votación no encontrada');
    }
  } catch (error) {
    console.error('Error al registrar el voto:', error);
    res.status(500).send('Error al registrar el voto');
  }
});


//SI FUNCIONA
app.get('/active-votings', async (req, res) => {
  try {
    const now = new Date();
    const activeVotings = await Voting.find({ startDate: { $lte: now }, endDate: { $gte: now } });
    console.log('Votaciones activas:', activeVotings); // Agregar este log
    res.status(200).json(activeVotings);
  } catch (error) {
    console.error('Error al obtener votaciones activas:', error);
    res.status(500).send('Error al obtener votaciones activas');
  }
});
/*
// Ruta para obtener el historial de votaciones de un usuario
app.get('/user-voting-history/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    // Verifica si el userId es un ObjectId válido
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: 'El ID de usuario no es válido' });
    }

    // Consulta para votaciones creadas por el usuario
    const createdVotings = await Voting.find({ creator: userId });

    // Consulta para votaciones donde el usuario ha votado
    const votedVotings = await Voting.aggregate([
      { $unwind: "$options" },
      { $unwind: "$options.votes" },
      // Busca votos donde el userId coincida con el ID de usuario proporcionado
      { $match: { "options.votes.userId": new mongoose.Types.ObjectId(userId) } },
      // Agrupa los resultados para formar el historial de votaciones
      {
        $group: {
          _id: "$_id",
          title: { $first: "$title" },
          options: {
            $push: {
              text: "$options.text",
              votes: "$options.votes",
            },
          },
        },
      },
    ]);

    // Combina ambas listas de votaciones y elimina duplicados si es necesario
    const combinedVotings = [...createdVotings, ...votedVotings].filter((voting, index, self) =>
      index === self.findIndex((v) => v._id.toString() === voting._id.toString())
    );

    res.status(200).json(combinedVotings);
  } catch (error) {
    console.error('Error al obtener el historial de votaciones:', error);
    res.status(500).json({ error: 'Error al obtener el historial de votaciones' });
  }
});*/

app.get('/user-voting-history/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    // Verifica si el userId es un ObjectId válido
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: 'El ID de usuario no es válido' });
    }

    // Consulta para votaciones creadas por el usuario
    const createdVotings = await Voting.find({ creator: userId });

    // Consulta para votaciones donde el usuario ha votado
    const votedVotings = await Voting.aggregate([
      { $unwind: "$options" },
      { $unwind: "$options.votes" },
      // Busca votos donde el userId coincida con el ID de usuario proporcionado
      { $match: { "options.votes.userId": new mongoose.Types.ObjectId(userId) } },
      // Agrupa los resultados para formar el historial de votaciones
      {
        $group: {
          _id: "$_id",
          title: { $first: "$title" },
          options: {
            $push: {
              text: "$options.text",
              votesCount: { $sum: 1 }
            },
          },
        },
      },
    ]);

    // Combina ambas listas de votaciones y elimina duplicados si es necesario
    const combinedVotings = [...createdVotings, ...votedVotings].filter((voting, index, self) =>
      index === self.findIndex((v) => v._id.toString() === voting._id.toString())
    );

    res.status(200).json(combinedVotings);
  } catch (error) {
    console.error('Error al obtener el historial de votaciones:', error);
    res.status(500).json({ error: 'Error al obtener el historial de votaciones' });
  }
});


// Ruta para obtener los datos de un usuario por su ID
app.get('/user/:userId', async (req, res) => {
  const userId = req.params.userId;

  try {
    const user = await User.findById(userId);
    if (user) {
      res.status(200).json({ email: user.email });
    } else {
      res.status(404).send('Usuario no encontrado');
    }
  } catch (error) {
    console.error('Error al obtener los datos del usuario:', error);
    res.status(500).send('Error al obtener los datos del usuario');
  }
});



app.listen(port, () => {
  console.log(`Servidor escuchando en http://localhost:${port}`);
});
