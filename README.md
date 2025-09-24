# Desafio Prático Salesforce - Monitoramento de SLA de Casos

Este repositório contém uma solução completa para o desafio prático de monitoramento de SLA de casos no Salesforce, incluindo automações, metadados, perfis, permission sets, batch apex, triggers, flows, approval processes e flexipages.

---

## 🚀 Funcionalidades

- **Trigger no objeto Caso:**  
  Define automaticamente a Data Limite para Resolução consultando o metadado SLA__mdt conforme a urgência do caso.

- **Batch Apex para monitoramento de casos:**  
  Executa a cada 5 minutos, eleva urgência para Alta em casos atrasados e envia e-mail ao gerente de suporte.

- **Perfis e Permission Sets:**  
  - *Agente de Suporte*: leitura/edição de casos, não pode alterar urgência manualmente.
  - *Gerente de Suporte*: acesso total, pode alterar urgência e reatribuir casos.
  - *Pode Alterar Urgência*: permission set com custom permission para permitir alteração da urgência após 30 minutos.

- **Metadado SLA__mdt:**  
  Define tempo padrão de resolução por urgência (Baixa, Média, Alta).

- **Record Types:**  
  - Suporte Técnico
  - Suporte Administrativo

- **Campos Customizados:**  
  - Urgência (picklist)
  - Motivo do Caso (picklist dependente)
  - Data Limite para Resolução (fórmula baseada no SLA)

- **Processo de Aprovação:**  
  Submissão automática ou manual de casos com urgência Alta para aprovação do gerente.

- **Flows:**  
  Automatizam submissão para aprovação e controle de status dos casos.

- **Flexipages:**  
  Layouts Lightning personalizados para monitoramento de SLA e casos.

---

## 🧪 Testes

- Todas as classes Apex possuem testes unitários.
- Cobertura de código garantida para triggers, batch, helpers e serviços.

---

## 👩‍💻 Autores

- Soraya Costa

---

## 📄 Licença

Este projeto é apenas para fins educacionais e de avaliação técnica.

---

**Dúvidas ou sugestões? Abra uma issue ou entre em contato!**