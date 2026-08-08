/// Contrato do controller da tela de splash.
///
/// Nao expoe estado observavel: apenas dispara, no `onInit`, a checagem de
/// sessao (`AuthControllerInterface.logado`) e a navegacao inicial para
/// `/home` ou `/login` apos o tempo minimo de exibicao da marca.
abstract class SplashControllerInterface {}
