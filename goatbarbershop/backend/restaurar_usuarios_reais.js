const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

async function restaurarUsuariosReais() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'barbearia_app'
    });

    console.log('Restaurando usuários reais...');

    // Gerar hash da senha "123456"
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('123456', salt);

    // Restaurar barbeiros
    const barbeiros = [
      { id: 1, nome: 'Haku Santos', email: 'haku@goatbarber.com', telefone: '(71) 98765-4321', cpf: '12345678901' },
      { id: 2, nome: 'Luon Yog', email: 'luon@goatbarber.com', telefone: '(71) 98765-4322', cpf: '12345678902' },
      { id: 3, nome: 'Oui Uiga', email: 'oui@goatbarber.com', telefone: '(71) 98765-4323', cpf: '12345678903' }
    ];

    for (const barbeiro of barbeiros) {
      await connection.execute(
        'INSERT INTO usuarios (id, nome, email, telefone, cpf, senha_hash, tipo_usuario, ativo) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [barbeiro.id, barbeiro.nome, barbeiro.email, barbeiro.telefone, barbeiro.cpf, hashedPassword, 'barbeiro', true]
      );
      console.log(`✓ Barbeiro ${barbeiro.nome} restaurado`);
    }

    // Restaurar carteiras dos barbeiros
    for (const barbeiro of barbeiros) {
      await connection.execute(
        'INSERT INTO carteiras (usuario_id, saldo) VALUES (?, ?)',
        [barbeiro.id, 0.00]
      );
      console.log(`✓ Carteira do barbeiro ${barbeiro.nome} criada`);
    }

    // Restaurar serviços
    const servicos = [
      { nome: 'Corte Masculino', descricao: 'Corte de cabelo masculino tradicional', preco: 35.00, duracao: 30 },
      { nome: 'Barba', descricao: 'Aparar e modelar barba', preco: 25.00, duracao: 30 },
      { nome: 'Corte + Barba (Completo)', descricao: 'Pacote completo: corte e barba', preco: 50.00, duracao: 60 }
    ];

    for (const servico of servicos) {
      await connection.execute(
        'INSERT INTO servicos (nome, descricao, preco_base, duracao_minutos) VALUES (?, ?, ?, ?)',
        [servico.nome, servico.descricao, servico.preco, servico.duracao]
      );
      console.log(`✓ Serviço ${servico.nome} restaurado`);
    }

    // Restaurar categorias de produtos
    const categorias = [
      { nome: 'Cremes e Pomadas', descricao: 'Produtos para modelagem e finalização de cabelo', tipo: 'produto' },
      { nome: 'Gel para Cabelo', descricao: 'Géis fixadores e modeladores', tipo: 'produto' },
      { nome: 'Esponjas e Acessórios', descricao: 'Acessórios para cuidados capilares', tipo: 'produto' },
      { nome: 'Cervejas', descricao: 'Cervejas nacionais e importadas', tipo: 'bebida' },
      { nome: 'Refrigerantes', descricao: 'Refrigerantes e bebidas gaseificadas', tipo: 'bebida' },
      { nome: 'Águas', descricao: 'Águas minerais e naturais', tipo: 'bebida' }
    ];

    for (const categoria of categorias) {
      await connection.execute(
        'INSERT INTO categorias_produto (nome, descricao, tipo) VALUES (?, ?, ?)',
        [categoria.nome, categoria.descricao, categoria.tipo]
      );
      console.log(`✓ Categoria ${categoria.nome} restaurada`);
    }

    // Restaurar produtos
    const produtos = [
      { categoria_id: 1, nome: 'Creme de cabelo(cachop)', descricao: 'Creme modelador para cabelos cacheados', preco: 27.99, estoque: 50, destaque: true },
      { categoria_id: 2, nome: 'gel para cabelo', descricao: 'Gel fixador extra forte', preco: 15.99, estoque: 80, destaque: true },
      { categoria_id: 3, nome: 'Esponja Nudred', descricao: 'Esponja twist para cabelos cacheados', preco: 24.99, estoque: 30, destaque: false },
      { categoria_id: 3, nome: 'Pata Pata', descricao: 'Escova modeladora profissional', preco: 4.99, estoque: 25, destaque: false },
      { categoria_id: 4, nome: 'Cerveja lata 350 ml', descricao: 'Cerveja pilsen gelada', preco: 8.99, estoque: 100, destaque: true },
      { categoria_id: 4, nome: 'Cerveja zero álcool', descricao: 'Cerveja sem álcool 350ml', preco: 15.99, estoque: 60, destaque: false },
      { categoria_id: 5, nome: 'Refrigerante lata 350 ml', descricao: 'Refrigerante cola gelado', preco: 6.99, estoque: 120, destaque: true },
      { categoria_id: 6, nome: 'Água mineral 500ml', descricao: 'Água mineral natural', preco: 3.50, estoque: 150, destaque: false }
    ];

    for (const produto of produtos) {
      await connection.execute(
        'INSERT INTO produtos (categoria_id, nome, descricao, preco, estoque, ativo, destaque) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [produto.categoria_id, produto.nome, produto.descricao, produto.preco, produto.estoque, true, produto.destaque]
      );
      console.log(`✓ Produto ${produto.nome} restaurado`);
    }

    console.log('\n✅ Todos os dados reais foram restaurados!');
    console.log('\nCredenciais de acesso:');
    console.log('Admin: admin@goatbarber.com / admin123');
    console.log('Barbeiros: haku@goatbarber.com, luon@goatbarber.com, oui@goatbarber.com / 123456');

    await connection.end();
  } catch (error) {
    console.error('Erro:', error);
  }
}

restaurarUsuariosReais();