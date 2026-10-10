/// Metodos HTTP aceitos pelo `HttpManager`.
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  const HttpMethod(this.valor);

  final String valor;
}
