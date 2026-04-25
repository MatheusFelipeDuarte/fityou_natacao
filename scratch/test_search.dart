
String removeDiacritics(String str) {
  var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
  var withoutDia = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';
  String result = str.toLowerCase();
  for (int i = 0; i < withDia.length; i++) {
    result = result.replaceAll(withDia[i], withoutDia[i]);
  }
  return result.trim();
}

void main() {
  var names = ['João Silva', 'André Souza', 'Matias Guedes', 'Matheus Duarte'];
  var queries = ['joao', 'andre', 'matias', 'matheus', 'silva', 'Mat'];

  for (var query in queries) {
    var q = removeDiacritics(query);
    print('Query: $query (normalized: $q)');
    var matches = names.where((name) => removeDiacritics(name).contains(q)).toList();
    print('  Matches: $matches');
  }
}
