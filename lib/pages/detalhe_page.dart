import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/ocorrencia.dart';
import '../services/central_service.dart';

class DetalhePage extends StatefulWidget {
  final Ocorrencia ocorrencia;

  const DetalhePage({
    super.key,
    required this.ocorrencia,
  });

  @override
  State<DetalhePage> createState() => _DetalhePageState();
}

class _DetalhePageState extends State<DetalhePage> {
  final service = CentralService();
  final pista = TextEditingController();

  bool enviando = false;

  @override
  void dispose() {
    pista.dispose();
    super.dispose();
  }

  Future<void> enviar() async {
    final mensagem = pista.text.trim();

    if (mensagem.isEmpty || enviando) {
      return;
    }

    setState(() {
      enviando = true;
    });

    try {
      await service.enviarPista(
        widget.ocorrencia.id,
        mensagem,
      );

      pista.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pista enviada com sucesso!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar pista: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  Future<void> alterarStatus() async {
    try {
      await service.alterarStatus(widget.ocorrencia);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status atualizado com sucesso!'),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar status: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.ocorrencia;

    final dono =
        FirebaseAuth.instance.currentUser?.uid == o.autorId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investigação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              o.titulo,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 8),

            Text('Local: ${o.local}'),

            Text('Registrado por: ${o.autorNome}'),

            const SizedBox(height: 8),

            Text(
              o.descricao.isEmpty
                  ? 'Sem descrição'
                  : o.descricao,
            ),

            const SizedBox(height: 12),

            if (dono)
              OutlinedButton.icon(
                 onPressed: () async {
              try {
                await service.alterarStatus(o);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e')));
              }
            },
            icon: const Icon(Icons.task_alt),
            label: Text(o.resolvido ? 'Reabrir' : 'Marcar como resolvido'),
          ),
            const Divider(),

            const Text(
              'Pistas da comunidade',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder(
                stream: service.pistas(o.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar pistas: ${snapshot.error}',
                      ),
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma pista ainda.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final d = docs[index].data();

                      return ListTile(
                        leading: const Icon(Icons.lightbulb_outline),
                        title: Text(
                          d['mensagem'] as String? ?? '',
                        ),
                        subtitle: Text(
                          d['autorNome'] as String? ?? 'Anônimo',
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pista,
                    decoration: const InputDecoration(
                      hintText: 'Compartilhe uma pista...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => enviar(),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: enviando ? null : enviar,
                  icon: enviando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
