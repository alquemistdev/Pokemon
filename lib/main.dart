import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MeusPokemons());
}

class Pokemons {
  List<Dados>? dados;

  Pokemons({this.dados});

  Pokemons.fromJson(Map<String, dynamic> json) {
    if (json['dados'] != null) {
      dados = <Dados>[];
      json['dados'].forEach((v) {
        dados!.add(Dados.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (dados != null) {
      data['dados'] = dados!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dados {
  int? id;
  String? name;
  String? img;
  String? num;
  String? type;
  String? height;
  String? weight;
  List<String>? weaknesses;

  Dados({
    this.id,
    this.name,
    this.img,
    this.num,
    this.type,
    this.height,
    this.weight,
    this.weaknesses,
  });

  Dados.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    img = json['img'];
    num = json['num'];
    type = json['type'][0].toString();
    height = json['height'];
    weight = json['weight'];
    weaknesses = json['weaknesses'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['num'] = num;
    data['name'] = name;
    data['img'] = img;
    data['num'] = num;
    data['type'] = type;
    data['height'] = height;
    data['weight'] = weight;
    data['weaknesses'] = weaknesses;

    return data;
  }
}

Future<List<Dados>> dados() async {
  final List<dynamic> result = await fetchUsers();
  //print(result);
  List<Dados> pokemons;
  pokemons = (result).map((pokemon) => Dados.fromJson(pokemon)).toList();
  return pokemons;
}

const String url =
    "https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json";

Future<List<dynamic>> fetchUsers() async {
  var result = await http.get(Uri.parse(url));
  return jsonDecode(result.body)['pokemon'];
}

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({
    Key? key,
  }) : super(key: key);

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Dados>>(
              future: dados(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('An error has occurred!'),
                  );
                } else if (snapshot.hasData) {
                  return PokemonsList(
                      pokemons: snapshot.data!
                          .where((pokemon) => pokemon.name!
                              .toLowerCase()
                              .contains(controller.text.toLowerCase()))
                          .toList());
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Color definirCor(String tipo) {
  switch (tipo) {
    case "Grass":
      return Colors.green;
    case "Fire":
      return Colors.red;
    case "Water":
      return Colors.blue;
    case "Poison":
      return Colors.deepPurple;
    case "Electric":
      return Colors.amber;
    case "Rock":
      return Colors.grey;
    case "Ground":
      return Colors.brown;
    case "Psychic":
      return Colors.indigo;
    case "Fighting":
      return Colors.orange;
    case "Bug":
      return Colors.lightGreen;
    case "Ghost":
      return const Color.fromARGB(221, 72, 72, 72);
    case "Normal":
      return const Color.fromARGB(221, 166, 166, 166);
    default:
      return const Color.fromARGB(221, 211, 211, 211);
  }
}

class Label extends StatelessWidget {
  Label({
    super.key,
    required this.label,
    required this.valor,
  });

  String label;
  String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class DetalhePokemon extends StatelessWidget {
  DetalhePokemon({super.key, required this.pokemon});

  var pokemon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name),
        backgroundColor: definirCor(pokemon.type!),
        shadowColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: definirCor(pokemon.type!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  "${pokemon.img}",
                  width: 200,
                  height: 200,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(20),
              width: 407,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(label: 'Numero', valor: pokemon.num),
                  const Divider(),
                  Label(label: 'Tipo', valor: pokemon.type),
                  const Divider(),
                  Label(label: 'Peso', valor: pokemon.weight),
                  const Divider(),
                  Label(label: 'Altura', valor: pokemon.height),
                  const Divider(),
                  Label(label: 'Fraquezas', valor: ''),
                  Text("${pokemon.weaknesses}",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PokemonsList extends StatelessWidget {
  const PokemonsList({Key? key, required this.pokemons}) : super(key: key);

  final List<Dados> pokemons;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black,
              offset: Offset(1, 2.0),
              blurRadius: 5,
              spreadRadius: 2),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: pokemons.length,
        itemBuilder: (context, index) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
            margin: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
                color: definirCor(pokemons[index].type!),
                borderRadius: BorderRadius.all(Radius.circular(25))),
            child: ListTile(
              title: Column(
                children: [
                  Text(
                    pokemons[index].name!.split(' ')[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.network("${pokemons[index].img}", height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        pokemons[index].id.toString(),
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<Widget>(builder: (BuildContext context) {
                    return DetalhePokemon(pokemon: pokemons[index]);
                  }),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MeusPokemons extends StatelessWidget {
  const MeusPokemons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaginaInicial(),
    );
  }
}
