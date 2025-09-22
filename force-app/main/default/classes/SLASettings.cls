public with sharing class SLASettings {
    private static Map<String, Integer> cache;

    // Mapeia chaves -> minutos (chaves em minúsculas)
    public static Map<String, Integer> minutesByKey() {
        if (cache != null) return cache;
        cache = new Map<String, Integer>();

        for (SLA__mdt row : [
            SELECT DeveloperName, Urgencia__c, MinutosParaResolucao__c
            FROM SLA__mdt
        ]) {
            Integer mins = (Integer) row.MinutosParaResolucao__c;
            if (mins == null) continue;

            // Chave pelo DeveloperName (ex.: Alta, Media, Baixa)
            if (row.DeveloperName != null)
                cache.put(row.DeveloperName.toLowerCase(), mins);

            // Chave pelo texto do campo Urgencia__c do MDT (ex.: "Média")
            if (row.Urgencia__c != null) {
                String u = row.Urgencia__c.toLowerCase();
                cache.put(u, mins);
                cache.put(normalize(u), mins); // fallback sem acento
            }
        }
        return cache;
    }

    // Normalização simples (remove acentos comuns em PT-BR)
    public static String normalize(String s) {
        if (s == null) return null;
        String t = s;
        t = t.replace('á','a').replace('à','a').replace('â','a').replace('ã','a').replace('ä','a')
             .replace('Á','a').replace('À','a').replace('Â','a').replace('Ã','a').replace('Ä','a');
        t = t.replace('é','e').replace('è','e').replace('ê','e').replace('ë','e')
             .replace('É','e').replace('È','e').replace('Ê','e').replace('Ë','e');
        t = t.replace('í','i').replace('ì','i').replace('î','i').replace('ï','i')
             .replace('Í','i').replace('Ì','i').replace('Î','i').replace('Ï','i');
        t = t.replace('ó','o').replace('ò','o').replace('ô','o').replace('õ','o').replace('ö','o')
             .replace('Ó','o').replace('Ò','o').replace('Ô','o').replace('Õ','o').replace('Ö','o');
        t = t.replace('ú','u').replace('ù','u').replace('û','u').replace('ü','u')
             .replace('Ú','u').replace('Ù','u').replace('Û','u').replace('Ü','u');
        t = t.replace('ç','c').replace('Ç','c');
        return t;
    }
}