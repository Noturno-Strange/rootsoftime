# ROOTS OF TIME

## 1. Objetivo geral

Desenvolver um jogo completo chamado **Roots of Time**, ambientado em uma pequena comunidade rural brasileira, inspirado na agricultura familiar, nas tradições culinárias antigas, na convivência comunitária e na simplicidade da vida no interior.

O jogo deverá utilizar gráficos 2D de alta definição, pintados à mão, sem pixel art, com perspectiva elevada em três quartos.

Deverá ser possível jogar individualmente ou em multiplayer cooperativo com até seis jogadores.

O diferencial será permitir que os jogadores produzam artesanalmente seus próprios alimentos, desde o cultivo dos ingredientes até a preparação das refeições, utilizando ferramentas, equipamentos e objetos presentes fisicamente no cenário.

O jogo deverá proporcionar nostalgia, tranquilidade, satisfação, liberdade, cooperação e progressão constante.

Não desenvolver apenas um protótipo ou uma demonstração técnica. Desenvolver uma experiência funcional, visualmente refinada, estável e expansível.

## 2. Pilares fundamentais

- Agricultura familiar brasileira.
- Culinária artesanal tradicional.
- Interações diretamente no cenário.
- Vida comunitária.
- Rotina familiar simplificada.
- Cooperação multiplayer.
- Progressão visual permanente.
- Descoberta de receitas e tradições.
- Excelente qualidade artística.
- Simplicidade técnica e estabilidade.

Todas as decisões de desenvolvimento deverão respeitar esses pilares.

## 3. Tecnologias

Utilizar:

- Godot 4 em versão estável.
- GDScript com tipagem estática.
- Renderização 2D nativa.
- Camera2D.
- CharacterBody2D.
- StaticBody2D.
- Area2D.
- CollisionShape2D.
- CollisionPolygon2D.
- TileMapLayer.
- Sprite2D.
- AnimatedSprite2D.
- AnimationPlayer.
- AnimationTree quando apropriado.
- Skeleton2D quando necessário.
- Y-Sort.
- NavigationAgent2D.
- Light2D.
- CanvasModulate.
- LightOccluder2D.
- GPUParticles2D.
- Shaders 2D.
- ENet para multiplayer.
- Servidor autoritativo.
- Arquitetura modular orientada a dados.
- Resources para definição de conteúdo.
- GUT ou infraestrutura equivalente de testes.
- Git.

Garantir funcionamento nativo no Linux e Windows.

Utilizar recursos nativos da engine sempre que possível.

Não desenvolver uma engine própria, não adicionar dependências desnecessárias e não criar sistemas excessivamente complexos.

## 4. Direção artística

Adotar gráficos 2D HD com aparência de pintura digital artesanal, perspectiva em três quartos, riqueza de detalhes e excelente acabamento.

O estilo deverá combinar:

- Ilustrações pintadas à mão.
- Proporções naturais.
- Arquitetura tradicional brasileira.
- Vegetação tropical detalhada.
- Cores naturais e harmoniosas.
- Iluminação atmosférica.
- Sombras suaves.
- Personagens expressivos.
- Animações fluidas.
- Objetos visualmente reconhecíveis.
- Texturas naturais de madeira, terra, cerâmica, tecido e pedra.

O cenário deverá transmitir aconchego, nostalgia e identidade cultural brasileira.

Utilizar as imagens conceituais fornecidas como referência principal.

Não utilizar pixel art, desenhos excessivamente infantis, formas geométricas improvisadas, recursos artísticos genéricos ou estilos visualmente incompatíveis.

Não utilizar a imagem conceitual inteira como cenário jogável. Reconstruir sua composição utilizando recursos gráficos independentes e interativos.

## 5. Cenário principal

Criar uma pequena comunidade rural brasileira cercada pela natureza.

No centro deverá existir um grande descampado de terra batida e grama, utilizado como espaço comunitário, ponto de encontro, local de brincadeiras e festividades.

Ao redor do descampado deverão existir casas tradicionais brasileiras, com paredes de alvenaria, telhados de cerâmica, portas e janelas de madeira, pequenas varandas e jardins.

Ao fundo deverá existir uma floresta densa, com uma trilha de terra conduzindo até uma pequena escola rural.

Incluir:

- Descampado comunitário.
- Casas familiares.
- Escola rural.
- Trilha da escola.
- Floresta.
- Plantações familiares.
- Casa de farinha.
- Moinho artesanal.
- Cozinha comunitária.
- Fogões a lenha.
- Terreiro para secagem de grãos.
- Galpão de ferramentas.
- Depósitos.
- Poço.
- Bancadas de trabalho.
- Pequena feira.
- Pomar.
- Galinheiro.
- Curral simplificado.
- Cercas.
- Árvores frutíferas.
- Quadro de avisos.
- Jardins.
- Bancos de madeira.
- Utensílios tradicionais.

Priorizar um mapa compacto, cuidadosamente planejado, com deslocamentos curtos e excelente densidade visual.

A floresta deverá funcionar como limite natural do cenário.

## 6. Construção modular do cenário

Separar os recursos gráficos em:

- Terrenos.
- Caminhos.
- Grama.
- Paredes.
- Pisos.
- Portas.
- Janelas.
- Telhados.
- Troncos.
- Copas.
- Cercas.
- Vegetação.
- Plantações.
- Personagens.
- Ferramentas.
- Alimentos.
- Equipamentos.
- Móveis.
- Recipientes.
- Sombras.
- Efeitos ambientais.

Utilizar TileMapLayer para terrenos e elementos modulares quando adequado.

Construções, árvores, móveis e equipamentos deverão possuir cenas reutilizáveis.

As casas deverão possuir interiores acessíveis.

Ao entrar em uma construção, ocultar ou tornar transparentes seus telhados e elementos superiores de maneira suave, revelando o interior.

A ocultação deverá ser local para cada jogador, evitando interferir na visão dos demais participantes.

## 7. Perspectiva e câmera

Utilizar perspectiva fixa em três quartos.

Implementar:

- Movimentação livre em oito direções.
- Câmera acompanhando suavemente o personagem.
- Zoom ajustável dentro de limites seguros.
- Limites de câmera.
- Transições suaves.
- Compatibilidade com diferentes proporções de tela.
- Opção de reduzir movimentação da câmera.

Não implementar rotação livre.

Todos os recursos gráficos deverão respeitar exatamente a mesma perspectiva e escala visual.

## 8. Posicionamento e profundidade

Implementar um sistema centralizado PlacementSystem2D.

Padronizar o ponto de origem dos personagens, árvores, construções, móveis e equipamentos na base de contato com o terreno.

Utilizar Y-Sort para ordenação visual.

Garantir que:

- Personagens apareçam corretamente atrás ou na frente das árvores.
- Copas permaneçam conectadas aos troncos.
- Objetos não pareçam flutuar ou estar afundados.
- Personagens não apareçam indevidamente sobre telhados.
- Ferramentas acompanhem corretamente as mãos.
- Objetos transportados acompanhem a profundidade do personagem.
- Móveis e paredes ocultem corretamente personagens.
- Plantações apresentem sobreposição natural.
- Sombras permaneçam conectadas aos objetos.

Não corrigir problemas de profundidade utilizando valores arbitrários de Z-index individualmente.

Criar regras centralizadas e reutilizáveis.

## 9. Colisões

Todos os objetos sólidos relevantes deverão possuir colisões adequadas.

A colisão deverá representar a área ocupada pelo objeto no terreno, e não necessariamente toda sua imagem.

Exemplos:

- Árvores: colisão na base do tronco.
- Casas: colisões nas paredes.
- Mesas: colisão na área ocupada.
- Cercas: colisões contínuas.
- Portas: colisão correspondente ao estado aberto ou fechado.
- Personagens: colisão próxima aos pés.
- Plantações: colisões ou áreas de interação conforme necessidade.
- Grama e flores: normalmente sem colisão.

Garantir que todas as entradas, trilhas e estações sejam acessíveis.

Validar automaticamente objetos sólidos sem colisão, caminhos bloqueados, equipamentos inacessíveis e sobreposições indevidas.

## 10. Personagens

Criar personagens masculinos e femininos em 2D HD, com proporções naturais e aparência compatível com a direção artística.

Permitir personalização de:

- Cabelos.
- Tons de pele.
- Roupas.
- Chapéus.
- Calçados.
- Acessórios.

Utilizar composição modular ou outro sistema reutilizável.

Todas as personalizações deverão acompanhar corretamente as animações.

Não permitir roupas, cabelos, ferramentas ou acessórios desconectados do personagem.

## 11. Animações

Utilizar sprite sheets de alta qualidade, animações esqueléticas 2D ou uma combinação dessas técnicas.

Implementar animações naturais para:

- Permanecer parado.
- Caminhar.
- Correr.
- Agachar.
- Sentar.
- Comer.
- Carregar objetos.
- Utilizar enxada.
- Plantar.
- Regar.
- Colher.
- Arrancar mandioca.
- Cortar alimentos.
- Descascar.
- Lavar.
- Ralar.
- Debulhar.
- Peneirar.
- Moer.
- Mexer panelas.
- Transportar cestos.
- Transportar sacos.
- Servir refeições.

Utilizar movimentação em oito direções.

Para atividades artesanais realizadas em estações fixas, utilizar posições e orientações predefinidas, reduzindo a quantidade de animações necessárias.

Sincronizar mãos, ferramentas, impactos, partículas e sons.

Proibir animações improvisadas, movimentos robóticos, personagens deslizando e ferramentas flutuantes.

Validar visualmente todas as animações.

## 12. Gameplay integrado ao cenário

Esta é uma regra fundamental e inegociável.

Todas as atividades principais deverão acontecer diretamente no ambiente jogável.

Não utilizar menus para substituir:

- Plantio.
- Colheita.
- Fabricação.
- Processamento.
- Culinária.
- Armazenamento.
- Entregas.
- Alimentação das crianças.

O jogador deverá aproximar-se dos equipamentos, pegar ferramentas, transportar ingredientes, manipular recipientes e executar as atividades no cenário.

Utilizar estados visuais, animações, pontos de encaixe e interações contextuais.

Não simular individualmente milhares de grãos, gotas ou partículas físicas.

A complexidade visual deverá ser produzida por sprites, animações e efeitos eficientes.

## 13. Controles

Implementar controles simples, responsivos e remapeáveis.

Configuração inicial sugerida:

- WASD ou setas: movimentação.
- Mouse: seleção contextual.
- Botão esquerdo: utilizar ferramenta.
- Botão direito: ação secundária.
- E: interagir.
- F: pegar ou posicionar objeto.
- Shift: correr.
- Teclas numéricas: selecionar ferramentas disponíveis.
- Esc: menu.

Utilizar destaques discretos nos objetos selecionados.

Não destacar permanentemente todos os objetos do cenário.

Validar distância, direção, disponibilidade e estado dos objetos antes de executar interações.

## 14. Agricultura familiar

Implementar uma agricultura familiar diversificada.

Cultivos fundamentais:

- Milho.
- Mandioca.
- Arroz.
- Feijão.

Cultivos adicionais:

- Cana-de-açúcar.
- Café.
- Amendoim.
- Abóbora.
- Batata-doce.
- Trigo.
- Tomate.
- Cebola.
- Alho.
- Couve.
- Cenoura.
- Alface.
- Pimenta.
- Banana.
- Goiaba.
- Coco.
- Laranja.
- Limão.
- Mamão.
- Manga.
- Maracujá.

Cada cultivo deverá possuir características próprias.

Implementar:

- Preparação da terra.
- Plantio.
- Irrigação.
- Crescimento por estágios.
- Colheita.
- Replantio.
- Armazenamento.
- Processamento.

Utilizar sprites exclusivos para cada espécie e seus estágios de crescimento.

Não representar diferentes plantas apenas alterando suas cores.

O crescimento deverá utilizar atualizações centralizadas, evitando processamento individual a cada frame.

Balancear os tempos de crescimento para favorecer sessões agradáveis, sem exigir esperas excessivas.

## 15. Pomar e criação simplificada de animais

Criar árvores frutíferas com estados visuais de crescimento, florescimento e produção.

Implementar galinhas e vacas de maneira simplificada, utilizando rotinas e animações predefinidas.

Produtos:

- Ovos.
- Leite.

Não desenvolver simulação complexa de reprodução, doenças, genética, necessidades fisiológicas ou comportamento animal avançado.

A criação de animais deverá complementar a culinária e permanecer tecnicamente simples.

Ingredientes de origem animal adicionais poderão ser adquiridos na feira, evitando implementar sistemas complexos de produção animal.

## 16. Sistema universal de processamento artesanal

Criar um sistema genérico ProcessingStation2D.

Todas as receitas deverão reutilizar operações fundamentais:

- Lavar.
- Descascar.
- Cortar.
- Ralar.
- Debulhar.
- Prensar.
- Secar.
- Peneirar.
- Moer.
- Misturar.
- Bater.
- Torrar.
- Cozinhar.
- Assar.
- Fritar.
- Fermentar.
- Coar.
- Modelar.
- Embalar.
- Armazenar.

Cada operação deverá ser definida por dados, ingredientes aceitos, ferramentas, duração, animações, efeitos e produtos resultantes.

Não desenvolver um sistema independente para cada alimento.

Utilizar máquinas de estados reutilizáveis.

## 17. Casa de farinha

Criar uma casa de farinha tradicional brasileira, funcional e detalhada.

Implementar a cadeia artesanal da mandioca:

1. Colher as raízes.
2. Transportar.
3. Lavar.
4. Descascar.
5. Ralar.
6. Prensar.
7. Peneirar.
8. Torrar.
9. Ensacar.
10. Armazenar.

Representar visualmente cada transformação.

Criar equipamentos apropriados, mecanismos animados, bancadas, peneiras, recipientes e forno artesanal.

Permitir futuramente utilizar subprodutos adequados da mandioca em outras receitas.

Pesquisar referências culturais confiáveis. As etapas deverão ser adaptadas ao gameplay e não apresentadas como instruções completas de preparo alimentar seguro.

## 18. Produção artesanal de milho

Permitir colher milho verde e milho maduro.

Implementar:

- Retirada das palhas.
- Debulhamento.
- Secagem.
- Ralação.
- Moagem.
- Peneiração.
- Preparação de massas.

Produzir:

- Fubá.
- Farinha de milho.
- Massa de milho.
- Milho debulhado.
- Milho cozido.
- Outros ingredientes intermediários.

Diferenciar corretamente farinha de milho e fubá, respeitando os métodos tradicionais da região representada.

O moinho deverá apresentar mecanismos animados, sons, partículas e recipientes com conteúdo visível.

## 19. Culinária artesanal ampla

A culinária deverá ser um dos principais sistemas do jogo.

Criar um catálogo expansível, capaz de suportar mais de 100 receitas sem exigir alterações na arquitetura central.

Implementar progressivamente as seguintes categorias.

### Receitas de milho

- Pamonha.
- Curau.
- Canjica.
- Bolo de milho.
- Bolo de fubá.
- Broa.
- Cuscuz.
- Angu.
- Polenta.
- Milho cozido.
- Sopa de milho.
- Mingau de milho.

### Receitas de mandioca

- Farinha de mandioca.
- Beiju.
- Tapioca.
- Bolo de mandioca.
- Mandioca cozida.
- Mandioca frita.
- Pirão.
- Farofa.
- Biscoito de polvilho.
- Pão de queijo.

### Receitas de arroz

- Arroz branco.
- Arroz temperado.
- Arroz carreteiro.
- Arroz-doce.
- Galinhada.
- Bolinho de arroz.

### Receitas de feijão

- Feijão tradicional.
- Tutu de feijão.
- Feijão tropeiro.
- Feijoada.
- Caldo de feijão.
- Baião de dois.

### Pães e massas

- Pão caseiro.
- Pão de milho.
- Pão de mandioca.
- Biscoitos artesanais.
- Roscas.
- Bolos simples.
- Macarrão caseiro.

### Laticínios

- Queijo fresco.
- Queijo curado.
- Manteiga.
- Requeijão.
- Doce de leite.

### Doces tradicionais

- Goiabada.
- Cocada.
- Pé de moleque.
- Paçoca.
- Rapadura.
- Melado.
- Doce de abóbora.
- Doce de banana.
- Doce de mamão.
- Compotas.
- Geleias.
- Bolos de frutas.

### Bebidas

- Café artesanal.
- Caldo de cana.
- Leite.
- Suco de laranja.
- Limonada.
- Suco de maracujá.
- Suco de goiaba.
- Suco de manga.
- Chás naturais.

### Refeições familiares

- Arroz com feijão.
- Ovos preparados.
- Omeletes.
- Sopas.
- Ensopados.
- Frango com quiabo.
- Galinha caipira.
- Legumes cozidos.
- Saladas.
- Refeições completas combinando diferentes acompanhamentos.

### Receitas festivas

- Comidas de festa junina.
- Bolos comemorativos.
- Doces comunitários.
- Cestas de café da manhã.
- Refeições para encontros familiares.
- Alimentos preparados para a escola.
- Pratos especiais de festividades.

O catálogo deverá ser implementado progressivamente, começando pelas receitas que compartilham os mesmos ingredientes e estações.

Não exigir todas as receitas na primeira versão jogável.

## 20. Cozinha artesanal

Criar cozinhas físicas funcionais.

Incluir:

- Fogão a lenha.
- Forno artesanal.
- Lenha.
- Panelas.
- Frigideiras.
- Colheres.
- Facas.
- Tábuas.
- Raladores.
- Pilões.
- Peneiras.
- Bancadas.
- Potes.
- Prateleiras.
- Água.
- Recipientes.

Permitir posicionar utensílios, adicionar ingredientes e preparar alimentos diretamente no cenário.

Representar o cozimento através de:

- Fogo.
- Fumaça.
- Vapor.
- Fervura.
- Mudanças de cor.
- Transformações dos ingredientes.
- Sons específicos.
- Alterações nos recipientes.

Utilizar tempos e temperaturas simplificados.

Permitir que os jogadores realizem outras atividades enquanto determinadas receitas cozinham.

Evitar cliques repetitivos e esperas improdutivas.

## 21. Manipulação e armazenamento físico

Implementar um sistema de objetos transportáveis.

Utilizar:

- Cestos.
- Sacos.
- Caixas.
- Potes.
- Baldes.
- Panelas.
- Bandejas.
- Prateleiras.
- Armários.
- Depósitos.

Permitir pegar, transportar, posicionar e transferir conteúdos.

Criar estados visuais de preenchimento:

- Vazio.
- Parcialmente preenchido.
- Meio cheio.
- Quase cheio.
- Cheio.

As quantidades deverão ser controladas por dados e representadas por sprites.

Não simular cada grão individualmente.

Utilizar pontos de encaixe para evitar objetos mal posicionados.

## 22. Sistema de crianças e escola

Implementar crianças como NPCs com rotinas simples e animações naturais.

O jogador terá exclusivamente três responsabilidades:

1. Levar as crianças à escola.
2. Buscar as crianças após as aulas.
3. Preparar e servir alimentos.

Não desenvolver sistemas complexos de criação de filhos.

Não implementar envelhecimento, crescimento, doenças, higiene, disciplina, educação avançada, necessidades emocionais ou gerenciamento escolar.

As crianças deverão possuir estados simples:

- Em casa.
- Aguardando refeição.
- Alimentando-se.
- Acompanhando o jogador.
- Na escola.
- Retornando para casa.

Utilizar NavigationAgent2D ou navegação equivalente.

As crianças deverão acompanhar o jogador pela trilha, desviar de obstáculos e chegar corretamente ao destino.

Ao servir alimentos, posicionar a refeição sobre a mesa. As crianças deverão sentar-se e executar animações de alimentação.

A rotina deverá possuir horários flexíveis.

Exemplo:

- 06:30: café da manhã.
- 07:00: levar à escola.
- 12:00: buscar na escola.
- 12:30: almoço.
- 18:30: jantar.

Qualquer jogador da sessão poderá realizar essas atividades.

Evitar punições severas por atrasos, ausência ou desconexão.

Criar mecanismos simples de recuperação quando um NPC ficar preso ou perder o caminho.

O sistema deverá complementar o gameplay, não dominar a experiência.

## 23. Escola rural

Construir uma escola pequena e visualmente detalhada.

A trilha até a escola deverá ser um dos pontos mais bonitos do cenário.

Incluir:

- Fachada tradicional.
- Entrada acessível.
- Sala de aula.
- Carteiras.
- Quadro.
- Pátio.
- Jardim.
- Local de entrega de alimentos.
- Professora ou professor com comportamento simples.

O jogador deverá acompanhar fisicamente as crianças até a escola e buscá-las no horário de saída.

Também poderá realizar encomendas comunitárias de alimentos para a escola.

Não transformar o jogo em um simulador escolar.

## 24. Objetivos cativantes

Criar objetivos com significado dentro da comunidade.

Objetivos imediatos:

- Preparar refeições para as crianças.
- Levar e buscar as crianças.
- Colher ingredientes.
- Produzir farinha.
- Preparar pamonhas.
- Fazer pão caseiro.
- Preparar café.
- Entregar encomendas.
- Organizar alimentos.

Objetivos intermediários:

- Restaurar o moinho.
- Recuperar a casa de farinha.
- Melhorar a cozinha.
- Ampliar plantações.
- Adquirir ferramentas.
- Desbloquear receitas.
- Melhorar depósitos.
- Ajudar moradores.
- Melhorar a escola.

Objetivos de longo prazo:

- Completar o livro de receitas tradicionais.
- Recuperar estruturas comunitárias.
- Transformar a comunidade visualmente.
- Construir uma produção artesanal diversificada.
- Organizar grandes festividades.
- Tornar a comunidade reconhecida por sua culinária.
- Dominar todas as técnicas artesanais.

Os objetivos deverão ser apresentados através de quadros de avisos, cartas, moradores, cadernos e elementos físicos.

Evitar tarefas genéricas sem contexto.

## 25. Progressão satisfatória

Implementar progressão individual e comunitária.

Habilidades individuais:

- Agricultura.
- Culinária.
- Processamento artesanal.

Progresso comunitário:

- Recuperação de construções.
- Melhorias de equipamentos.
- Desenvolvimento da escola.
- Expansão de áreas produtivas.
- Decorações.
- Novas receitas.
- Festividades.
- Novos estabelecimentos.

As recompensas deverão produzir alterações visíveis.

Exemplos:

- Moinho antigo restaurado.
- Cozinha reformada.
- Novas bancadas.
- Cestos maiores.
- Ferramentas melhores.
- Plantações ampliadas.
- Escola decorada.
- Descampado preparado para festividades.

Evitar progressão baseada exclusivamente em números.

Preservar a identidade artesanal durante toda a evolução.

Não transformar a comunidade em uma indústria automatizada.

## 26. Qualidade dos alimentos

Implementar um sistema simples de qualidade.

A qualidade poderá depender de:

- Frescor dos ingredientes.
- Domínio da receita.
- Preparação adequada.
- Controle simplificado do cozimento.
- Equipamentos utilizados.

Utilizar categorias compreensíveis:

- Simples.
- Boa.
- Excelente.
- Especial.

Cada categoria deverá possuir representação visual discreta.

Alimentos de qualidade superior poderão gerar melhores recompensas e reconhecimento comunitário.

Evitar cálculos excessivamente complexos.

Receitas malsucedidas não deverão causar punições desproporcionais.

## 27. Livro de receitas e tradições

Criar um caderno físico disponível dentro da cozinha.

O jogador deverá aproximar-se do caderno para consultar suas páginas.

Incluir:

- Ilustrações dos alimentos.
- Ingredientes.
- Quantidades.
- Etapas.
- Ferramentas.
- Estações necessárias.
- Domínio da receita.
- Descrição cultural.
- Receitas descobertas.
- Histórico de produção.

As novas receitas poderão ser aprendidas através de moradores, livros, eventos e progressão.

Utilizar uma apresentação ampliada e acessível para leitura.

Consultar uma receita nunca deverá executar automaticamente sua preparação.

## 28. Economia

Criar uma economia simples.

Permitir vender produtos em bancas, estabelecimentos e pontos físicos de entrega.

Os recursos obtidos poderão ser utilizados para:

- Comprar sementes.
- Adquirir utensílios.
- Melhorar ferramentas.
- Adquirir ingredientes.
- Reformar construções.
- Comprar decorações.
- Melhorar equipamentos.
- Financiar projetos comunitários.

Utilizar preços orientados a dados.

Evitar sistemas financeiros complexos, empréstimos, dívidas e gerenciamento econômico excessivo.

A economia deverá apoiar o gameplay, não se tornar o objetivo exclusivo.

## 29. Eventos e festividades

Criar eventos baseados no calendário interno do jogo.

Implementar progressivamente:

- Festa junina.
- Festival do milho.
- Festival da mandioca.
- Feira gastronômica.
- Mutirão comunitário.
- Almoço comunitário.
- Celebrações escolares.
- Festival de doces.
- Festa da colheita.
- Confraternizações.

Os eventos deverão transformar visualmente o descampado central.

Utilizar bandeirinhas, mesas, iluminação, decorações, alimentos e moradores.

Os eventos deverão gerar objetivos variados, especialmente relacionados à culinária.

Não utilizar recompensas dependentes do calendário real, punições por ausência ou tarefas diárias obrigatórias.

O jogador deverá retornar pela diversão e vontade de continuar sua história.

## 30. Multiplayer cooperativo

Suportar de 1 a 6 jogadores.

Todas as atividades essenciais deverão ser possíveis individualmente.

Não criar profissões obrigatórias.

Permitir que os jogadores dividam livremente as tarefas.

Exemplo:

- Um jogador cultiva milho.
- Outro produz farinha.
- Outro prepara refeições.
- Outro cuida dos depósitos.
- Outro acompanha as crianças.
- Outro realiza encomendas.

Utilizar servidor autoritativo para controlar:

- Plantações.
- Objetos.
- Ingredientes.
- Recipientes.
- Equipamentos.
- Receitas.
- Crianças.
- Horários.
- Economia.
- Objetivos.
- Progresso.
- Salvamentos.

Validar todas as ações relevantes.

Impedir:

- Duplicação de itens.
- Colheitas simultâneas indevidas.
- Recompensas duplicadas.
- Alterações inválidas de inventário.
- Processamento sem ingredientes.
- Interações fora da distância permitida.
- Perda de objetos durante desconexões.

Utilizar interpolação para movimentação remota.

Sincronizar estados e eventos, não cada quadro de animação ou partícula.

## 31. Sessões multiplayer

Implementar:

- Modo individual.
- Criação de partidas.
- Salas privadas.
- Entrada por endereço.
- Convites quando houver infraestrutura apropriada.
- Identificação de jogadores.
- Chat de texto.
- Reconexão.
- Entrada em partidas existentes.
- Salvamento compartilhado.

O modo individual deverá utilizar a mesma lógica autoritativa local.

Evitar manter duas implementações diferentes de gameplay.

Definir uma estratégia de conectividade pela internet considerando NAT, encaminhamento de portas ou relay.

Não presumir que ENet sozinho resolve todas as conexões externas.

A comunicação por voz poderá ser implementada posteriormente, sem comprometer a estabilidade do projeto.

## 32. Balanceamento cooperativo

Ajustar quantidades de encomendas e carga de trabalho conforme o número de participantes.

Não obrigar o jogador individual a realizar o trabalho equivalente a seis pessoas.

Não alterar quantidades de objetivos em andamento arbitrariamente quando alguém desconectar.

Permitir cooperação vantajosa sem tornar a experiência individual inferior.

O progresso deverá permanecer consistente independentemente do número de jogadores.

## 33. Interface visual

Criar uma interface elegante, discreta, moderna e acolhedora.

Inspirar-se em papel artesanal, cadernos antigos, madeira, elementos botânicos e materiais naturais.

Paleta principal:

- Creme artesanal: #F3E5CC.
- Madeira: #78543B.
- Verde natural: #61774A.
- Amarelo milho: #D9AB4D.
- Terracota: #AD6546.
- Terra escura: #302C25.

Utilizar Lora para títulos e Nunito Sans para textos, ou fontes equivalentes devidamente licenciadas.

Criar ícones exclusivos para alimentos, ferramentas, receitas e equipamentos.

Não utilizar emojis como recursos gráficos definitivos.

Evitar interfaces futuristas, botões genéricos, excesso de transparência e painéis visualmente poluídos.

## 34. HUD minimalista

Exibir apenas informações essenciais:

- Dia.
- Horário.
- Clima.
- Ferramenta selecionada.
- Objeto transportado.
- Instruções contextuais.
- Notificações importantes.
- Objetivo selecionado, quando necessário.
- Indicadores multiplayer relevantes.

Permitir ocultar elementos não essenciais.

Não utilizar grandes painéis durante a exploração.

A HUD não deverá executar atividades artesanais remotamente.

O cenário deverá permanecer como foco visual principal.

## 35. Design System

Criar um tema global reutilizável.

Centralizar:

- Cores.
- Tipografia.
- Espaçamentos.
- Bordas.
- Ícones.
- Botões.
- Painéis.
- Tooltips.
- Notificações.
- Animações.
- Estados de foco.
- Estados de erro.
- Estados de indisponibilidade.

Utilizar Theme, Control, CanvasLayer, Containers, NinePatchRect, StyleBoxFlat, StyleBoxTexture e Tween.

Garantir:

- Compatibilidade com diferentes resoluções.
- Suporte a ultrawide.
- Escala ajustável.
- Textos legíveis.
- Remapeamento de comandos.
- Navegação por teclado e mouse.
- Opção de reduzir animações.
- Contraste adequado.
- Traduções em português brasileiro e inglês.

Não implementar botões fictícios.

## 36. Feedback visual e sonoro

Toda atividade deverá produzir uma resposta satisfatória.

Exemplos:

- Terra movimentando-se durante o uso da enxada.
- Água saindo do regador.
- Plantas balançando.
- Mandioca saindo do solo.
- Espigas sendo removidas.
- Grãos caindo em recipientes.
- Moinho girando.
- Farinha acumulando.
- Peneiras movimentando-se.
- Massa mudando de aparência.
- Pamonhas sendo montadas.
- Fogo reagindo à lenha.
- Panelas fervendo.
- Pães crescendo.
- Queijos mudando de estado.
- Cestos sendo preenchidos.
- Sacos aumentando de volume.
- Crianças sentando-se para comer.
- Construções sendo restauradas.

Sincronizar efeitos visuais, sons, animações e mudanças reais de estado.

Não utilizar barras de progresso como principal representação das atividades.

Não reproduzir efeitos de sucesso quando o servidor rejeitar uma ação.

## 37. Iluminação e efeitos modernos

Utilizar técnicas de renderização 2D para criar profundidade e atmosfera.

Implementar:

- Ciclo de dia e noite.
- Amanhecer dourado.
- Entardecer acolhedor.
- Iluminação ambiental dinâmica.
- Luzes quentes dentro das casas.
- Luz do fogão a lenha.
- Sombras de contato.
- Normal maps seletivos.
- Chuva.
- Neblina discreta.
- Movimento da vegetação.
- Poeira.
- Fumaça.
- Vapor.
- Reflexos estilizados.
- Folhas caindo.
- Insetos luminosos quando apropriado.

Combinar iluminação pintada e dinâmica de maneira consistente.

Evitar efeitos exagerados que prejudiquem a legibilidade ou a direção artística.

## 38. Áudio

Criar uma paisagem sonora rural brasileira.

Implementar áudio ambiental e espacialização 2D para:

- Pássaros.
- Vento.
- Insetos.
- Folhas.
- Chuva.
- Água.
- Madeira.
- Fogo.
- Ferramentas.
- Passos.
- Grãos.
- Moinhos.
- Panelas.
- Atividades comunitárias.

Utilizar variações sonoras para reduzir repetições perceptíveis.

Adicionar trilha instrumental suave, original ou devidamente licenciada, inspirada na música rural brasileira.

Permitir controle independente de música, ambiente, efeitos e comunicação.

## 39. Arquitetura modular

Organizar o projeto utilizando componentes reutilizáveis.

Sistemas fundamentais:

- PlayerController2D.
- InteractionSystem2D.
- PlacementSystem2D.
- CarrySystem.
- SnapPointSystem2D.
- CropSystem.
- OrchardSystem.
- AnimalProductSystem.
- ContainerSystem.
- ProcessingStation2D.
- RecipeSystem.
- CookingSystem.
- FoodQualitySystem.
- ChildRoutineSystem.
- SchoolSystem.
- CommunitySystem.
- QuestSystem.
- EventSystem.
- ProgressionSystem.
- EconomySystem.
- NetworkManager.
- SaveManager.
- AudioManager.
- UIManager.

Criar apenas os sistemas que forem necessários em cada fase.

Evitar arquitetura excessivamente abstrata, scripts gigantes, dependências circulares e duplicação de lógica.

Separar regras de gameplay, estado autoritativo, apresentação gráfica, interface e dados de conteúdo.

## 40. Estrutura de diretórios

Organizar o projeto aproximadamente da seguinte maneira:

    RootsOfTime/
    ├── AGENTS.md
    ├── README.md
    ├── project.godot
    ├── docs/
    ├── assets/
    │   ├── terrain/
    │   ├── buildings/
    │   ├── vegetation/
    │   ├── characters/
    │   ├── animations/
    │   ├── children/
    │   ├── crops/
    │   ├── animals/
    │   ├── tools/
    │   ├── food/
    │   ├── equipment/
    │   ├── furniture/
    │   ├── effects/
    │   ├── icons/
    │   ├── fonts/
    │   └── audio/
    ├── scenes/
    │   ├── world/
    │   ├── interiors/
    │   ├── player/
    │   ├── npc/
    │   ├── school/
    │   ├── objects/
    │   └── stations/
    ├── systems/
    │   ├── interaction/
    │   ├── agriculture/
    │   ├── processing/
    │   ├── cooking/
    │   ├── storage/
    │   ├── family/
    │   ├── community/
    │   ├── progression/
    │   ├── multiplayer/
    │   └── save/
    ├── content/
    │   ├── crops/
    │   ├── items/
    │   ├── recipes/
    │   ├── quests/
    │   └── events/
    ├── ui/
    │   ├── design_system/
    │   ├── components/
    │   ├── hud/
    │   └── screens/
    ├── shaders/
    ├── tools/
    ├── tests/
    └── reports/

Adaptar a estrutura quando houver justificativa técnica.

## 41. Desempenho

Priorizar um jogo leve, mesmo com gráficos de alta qualidade.

Estabelecer como meta inicial 1080p a 60 FPS estáveis ou superiores em hardware equivalente a Ryzen 7 5700G e Radeon RX 6600.

Validar o desempenho em hardware real.

Utilizar:

- Atlas de texturas.
- Reutilização de recursos.
- Agrupamento de objetos estáticos.
- Limites de partículas.
- Atualizações centralizadas.
- Colisões simplificadas.
- Controle de iluminação dinâmica.
- Ativação seletiva de sistemas.
- Sincronização eficiente.
- Carregamento otimizado.
- Resoluções adequadas dos sprites.

Evitar texturas gigantescas sem necessidade.

Não executar processamento individual a cada frame para centenas de plantas.

Implementar configurações gráficas baixa, média, alta e personalizada.

## 42. Salvamento

Implementar salvamentos versionados, gravação atômica e recuperação de falhas.

Salvar:

- Plantações.
- Estágios de crescimento.
- Objetos posicionados.
- Ferramentas.
- Recipientes.
- Ingredientes.
- Alimentos.
- Processamentos em andamento.
- Receitas.
- Dinheiro.
- Objetivos.
- Crianças.
- Estado da rotina escolar.
- Melhorias.
- Personalizações.
- Identidades dos participantes.
- Estado comunitário.
- Configurações.

Manter backup do último salvamento válido.

Garantir consistência durante desconexões e encerramento de partidas.

## 43. Ferramentas automáticas de qualidade

Implementar validadores conforme a necessidade do projeto.

### WorldValidator

Detectar posicionamento incorreto, sobreposições, caminhos bloqueados, escalas inconsistentes e objetos inacessíveis.

### AssetValidator

Verificar transparência, dimensões, recursos ausentes, origens, nomenclatura e referências.

### CollisionValidator

Detectar objetos sólidos sem colisão e formas de colisão inválidas.

### AnimationValidator

Verificar animações, quadros, estados, eventos e pontos de alinhamento.

### RecipeValidator

Detectar ingredientes ausentes, receitas impossíveis, dependências inválidas e resultados inconsistentes.

### NPCValidator

Verificar caminhos, pontos de destino, estados e recuperação de NPCs presos.

### NetworkValidator

Testar concorrência, sincronização, duplicação de objetos e desconexões.

### SaveValidator

Verificar gravação, carregamento, integridade e recuperação de falhas.

### PerformanceMonitor

Monitorar FPS, tempo de frame, memória, quantidade de objetos e utilização de recursos.

Criar um modo de inspeção para visualizar colisões, origens, pontos de encaixe, áreas de interação e informações de desempenho.

## 44. Controle de qualidade visual

Nenhum cenário deverá ser considerado concluído sem inspeção visual.

Verificar:

- Árvores corretamente posicionadas.
- Copas conectadas aos troncos.
- Sombras coerentes.
- Objetos sem aparência de flutuação.
- Colisões funcionais.
- Casas acessíveis.
- Perspectiva consistente.
- Personagens proporcionais.
- Animações naturais.
- Ferramentas alinhadas.
- Plantas reconhecíveis.
- Alimentos visualmente distintos.
- Interfaces legíveis.
- Ausência de fundos indevidos nos sprites.
- Ordenação visual correta.
- Telhados ocultados corretamente.
- Crianças seguindo caminhos acessíveis.

Criar pontos fixos de captura de imagens para comparar versões e detectar regressões visuais.

Testes automatizados deverão complementar a inspeção visual, não substituí-la.

## 45. Testes obrigatórios

Executar testes automatizados e testes gráficos reais.

Validar:

- Movimentação.
- Câmera.
- Colisões.
- Profundidade.
- Animações.
- Plantio.
- Crescimento.
- Colheita.
- Processamento.
- Culinária.
- Armazenamento.
- Entregas.
- Rotina escolar.
- Alimentação das crianças.
- Objetivos.
- Progressão.
- Economia.
- Interface.
- Salvamento.
- Multiplayer.
- Reconexão.
- Ações simultâneas.
- Desempenho.

Testar partidas com um, dois e seis jogadores.

Verificar o comportamento quando dois jogadores tentarem utilizar a mesma estação, colher a mesma planta ou pegar o mesmo objeto.

Testar desconexões durante atividades artesanais e durante o acompanhamento das crianças.

Executar testes headless quando apropriado.

Também executar o jogo graficamente, capturar imagens e inspecionar os resultados.

Nunca considerar uma funcionalidade concluída apenas porque compila.

Caso determinada validação não possa ser executada, registrá-la explicitamente como pendente.

## 46. Desenvolvimento por fases

### Fase 1 — Fundação

Criar arquitetura, documentação, padrões artísticos, Design System, testes e infraestrutura multiplayer básica.

### Fase 2 — Vertical Slice

Construir uma pequena área com qualidade gráfica próxima da versão final.

Incluir:

- Uma casa.
- Terreno.
- Vegetação.
- Personagem animado.
- Plantação de milho.
- Ferramentas.
- Cestos.
- Moinho.
- Cozinha.
- Interface minimalista.

Implementar completamente:

Preparar a terra → Plantar → Regar → Colher → Transportar → Processar → Produzir alimento → Entregar.

Validar individualmente e com dois jogadores.

Não expandir o cenário enquanto essa experiência não estiver funcional e satisfatória.

### Fase 3 — Cenário

Construir descampado, casas, floresta, trilha, escola e estabelecimentos comunitários.

### Fase 4 — Agricultura

Implementar milho, mandioca, arroz e feijão.

### Fase 5 — Culinária inicial

Implementar farinha de mandioca, farinha de milho, fubá, pamonha, arroz com feijão e outras receitas que compartilhem os primeiros equipamentos.

### Fase 6 — Crianças e escola

Implementar levar à escola, buscar e servir refeições.

Validar navegação, horários, animações e recuperação de falhas.

### Fase 7 — Expansão culinária

Adicionar novos cultivos, frutas, ovos, leite, doces, pães, queijos, bebidas e refeições.

Reutilizar os sistemas de processamento existentes.

### Fase 8 — Progressão comunitária

Implementar encomendas, melhorias, economia, livro de receitas e festividades.

### Fase 9 — Multiplayer completo

Validar seis jogadores, conexões externas, reconexões, concorrência e salvamentos compartilhados.

### Fase 10 — Polimento

Aprimorar gráficos, animações, iluminação, áudio, interface, acessibilidade e desempenho.

### Fase 11 — Validação final

Executar testes completos, corrigir regressões e gerar versões distribuíveis para Linux e Windows.

Não avançar enquanto existirem problemas críticos nas funcionalidades anteriores.

## 47. Documentação permanente

Criar e manter:

- AGENTS.md.
- README.md.
- GAME_DESIGN.md.
- ARCHITECTURE.md.
- ART_DIRECTION.md.
- ASSET_STANDARDS.md.
- ANIMATION_STANDARDS.md.
- INTERACTION_STANDARDS.md.
- CULINARY_SYSTEM.md.
- FAMILY_SYSTEM.md.
- UI_DESIGN_SYSTEM.md.
- MULTIPLAYER.md.
- QUALITY_CONTROL.md.
- TEST_PLAN.md.
- ROADMAP.md.
- THIRD_PARTY_LICENSES.md.

Documentar decisões, limitações, padrões técnicos, referências culturais e resultados reais dos testes.

O arquivo AGENTS.md deverá estabelecer regras obrigatórias para todos os agentes de inteligência artificial que trabalharem no projeto.

## 48. Regras absolutas para a inteligência artificial

- Não criar branches sem autorização.
- Não adicionar inteligência artificial como coautora dos commits.
- Não realizar alterações destrutivas sem autorização.
- Não implementar funcionalidades fictícias.
- Não apresentar sistemas incompletos como concluídos.
- Não utilizar placeholders como recursos definitivos.
- Não esconder erros.
- Não desativar testes para simular sucesso.
- Não inventar resultados de testes.
- Não adicionar dependências desnecessárias.
- Não utilizar recursos de licença desconhecida.
- Não misturar estilos artísticos incompatíveis.
- Não utilizar uma imagem estática inteira como substituta de um cenário interativo.
- Não substituir gameplay por menus.
- Não criar física excessivamente complexa.
- Não modificar sistemas estáveis sem justificativa.
- Não sacrificar qualidade para aumentar artificialmente a quantidade de conteúdo.
- Não ignorar problemas de colisão, profundidade ou animação.
- Não avançar enquanto existirem problemas críticos.
- Não declarar validação visual sem realizar inspeção correspondente.

Após cada etapa, apresentar:

1. Funcionalidades implementadas.
2. Arquivos modificados.
3. Testes executados.
4. Resultados reais.
5. Capturas disponíveis.
6. Problemas encontrados.
7. Correções realizadas.
8. Limitações restantes.
9. Próxima etapa recomendada.

## 49. Critério final de qualidade

O resultado deverá ser um jogo 2D HD bonito, funcional, acolhedor, otimizado e satisfatório.

O jogador deverá sentir que vive em uma pequena comunidade rural brasileira.

Deverá poder plantar, colher, transportar ingredientes, produzir farinha, preparar pamonhas, fazer pães, doces, queijos, bebidas e refeições utilizando métodos artesanais representados dentro do cenário.

Também deverá poder acompanhar as crianças até a escola, buscá-las e servir refeições, sem sistemas familiares desnecessariamente complexos.

Os amigos deverão conseguir compartilhar o mesmo mundo, dividir tarefas, preparar alimentos, cumprir objetivos e transformar a comunidade.

A diversão deverá surgir das atividades artesanais, das transformações visuais, do domínio das receitas, da evolução permanente da comunidade e da cooperação.

Roots of Time deverá transmitir a beleza das pequenas coisas, o valor das tradições e a satisfação de transformar ingredientes simples em alimentos feitos pelas próprias mãos.

Priorizar sempre uma experiência menor, bonita e extremamente bem executada em vez de um projeto gigantesco com funcionalidades superficiais.

**Roots of Time — From the land to the table, from tradition to eternity.**
