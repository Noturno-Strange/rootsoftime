# Arquitetura

A cena de entrada monta terreno, objetos ordenados pela base, personagens, câmera e interface. O código de apresentação consulta o estado da vila. As ações passam por validação de alvo, distância e intervalo no anfitrião antes de chegar às regras da fazenda.

| Responsabilidade | Arquivo |
| --- | --- |
| Cultivo, inventário, máquinas, família e economia | systems/farm.gd |
| Entradas, rede, tempo e apresentação | systems/village.gd |
| Implantação, paredes e canteiros | systems/placement.gd |
| Navegação na grade de colisão | systems/paths.gd |
| Animação e carga | systems/actor.gd |
| Salvamento local e recuperação | systems/save.gd |
| Música, efeitos e clima | systems/ambience.gd, systems/sound.gd, systems/weather.gd |
| Caderno e HUD | ui/journal.gd |
| Atlas de imagens e transformações artesanais | content/atlas.json, content/recipes.json |

O servidor avança um relógio de jogo. Uma receita armazena seu produto e instante de término. Os cultivos guardam espécie, estágio e instante de maturação. Desconectar durante um processamento não cancela o trabalho da estação.
