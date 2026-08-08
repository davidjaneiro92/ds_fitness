import 'package:get/get.dart';

import '../../../../enum/grupo_muscular.dart';
import '../../../../enum/periodo_estatistica.dart';
import '../../../../models/exercicio.dart';

/// Contrato do controller da tela 18 — Biblioteca de Exercicios.
abstract class BibliotecaControllerInterface {
  RxList<Exercicio> get exercicios;

  RxString get busca;

  Rx<BibliotecaFiltro> get filtro;

  Rxn<GrupoMuscular> get grupoFiltro;

  RxBool get carregando;

  /// Lista ja aplicando busca, filtro rapido e grupo muscular selecionado.
  List<Exercicio> get filtrados;

  Future<void> carregar();

  void buscar(String termo);

  void selecionarFiltro(BibliotecaFiltro novo);

  void selecionarGrupo(GrupoMuscular? grupo);

  Future<void> alternarFavorito(String id);

  void abrirDetalhe(Exercicio exercicio);
}
