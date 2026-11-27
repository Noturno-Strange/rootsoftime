# Validação desta edição

| Verificação | Resultado observado |
| --- | --- |
| Importação do projeto | Godot 4.7.2 estável |
| Regras, alcance e atlas | 453 verificações automatizadas aprovadas |
| Rede local | Um anfitrião e um convidado, depois um anfitrião e três convidados em processos separados |
| Lotação | Quinta conexão recusada durante partida com quatro jogadores |
| Feira cooperativa | Dois convidados vendem mangas enquanto o terceiro transporta milho. Os três recebem o saldo de seis moedas |
| Concorrência | Uma única carga de milho para participantes que disputam o mesmo canteiro |
| Desconexão e reentrada | Carga devolvida ao baú, senha incorreta recusada e estado do anfitrião recuperado na reentrada |
| Salvamento | Rotação de backup e recuperação após substituir o arquivo principal por dados inválidos |
| Renderização | Sessão X11 usando Mesa llvmpipe, captura da vila, do interior, do caderno e da refeição |
| Executáveis | Linux x86-64 executado graficamente. Windows x86-64 exportado |
| Desempenho e rede externa | Medição no Ryzen 7 5700G com RX 6600, teste em Windows e conexão pela internet pendentes |

Os testes revelaram uma cópia de backup dependente do diretório atual, enquadramento de câmera que expunha a borda do mapa e mensagens de estado acima do tamanho desejado para o canal de movimento. A cópia passou a usar caminhos absolutos da Godot. Os limites agora se aplicam ao centro deslocado. O estado da fazenda usa um canal confiável separado dos pacotes de posição.

As capturas estão em [vila](../reports/vila.jpg), [horta](../reports/horta.jpg), [refeição](../reports/refeicao.jpg), [interior](../reports/interior.jpg) e [caderno](../reports/caderno.jpg). O aviso de VSync é específico do driver gráfico virtual usado nos testes.
