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

  /// Recarrega o catalogo. Com [silencioso], mantem a lista na tela enquanto
  /// busca (usado ao voltar de outra tela, para nao piscar o carregamento).
  Future<void> carregar({bool silencioso = false});

  void buscar(String termo);

  void selecionarFiltro(BibliotecaFiltro novo);

  void selecionarGrupo(GrupoMuscular? grupo);

  Future<void> alternarFavorito(String id);

  /// Abre o detalhe e, ao voltar, atualiza a lista (favorito, recentes,
  /// edicao ou exclusao feitos la dentro).
  Future<void> abrirDetalhe(Exercicio exercicio);

  /// Abre o formulario de exercicio novo e atualiza a lista se algo foi salvo.
  Future<void> novoExercicio();
}
