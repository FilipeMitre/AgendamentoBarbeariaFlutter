const mysql = require('mysql2/promise');

async function restaurar() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      database: 'barbearia_app'
    });

    // Restaurar barbeiros
    await connection.execute(`INSERT IGNORE INTO usuarios (id, nome, email, telefone, cpf, senha_hash, tipo_usuario, ativo) VALUES
      (1, 'Haku Santos', 'haku@goatbarber.com', '(71) 98765-4321', '12345678901', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'barbeiro', TRUE),
      (2, 'Luon Yog', 'luon@goatbarber.com', '(71) 98765-4322', '12345678902', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'barbeiro', TRUE),
      (3, 'Oui Uiga', 'oui@goatbarber.com', '(71) 98765-4323', '12345678903', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'barbeiro', TRUE)`);

    // Restaurar carteiras
    await connection.execute(`INSERT IGNORE INTO carteiras (usuario_id, saldo) VALUES (1, 0.00), (2, 0.00), (3, 0.00)`);

    // Restaurar serviços
    await connection.execute(`INSERT IGNORE INTO servicos (nome, descricao, preco_base, duracao_minutos) VALUES
      ('Corte Masculino', 'Corte de cabelo masculino tradicional', 35.00, 30),
      ('Barba', 'Aparar e modelar barba', 25.00, 30),
      ('Corte + Barba (Completo)', 'Pacote completo: corte e barba', 50.00, 60)`);

    // Restaurar categorias
    await connection.execute(`INSERT IGNORE INTO categorias_produto (nome, descricao, tipo) VALUES
      ('Cremes e Pomadas', 'Produtos para modelagem e finalização de cabelo', 'produto'),
      ('Gel para Cabelo', 'Géis fixadores e modeladores', 'produto'),
      ('Esponjas e Acessórios', 'Acessórios para cuidados capilares', 'produto'),
      ('Cervejas', 'Cervejas nacionais e importadas', 'bebida'),
      ('Refrigerantes', 'Refrigerantes e bebidas gaseificadas', 'bebida'),
      ('Águas', 'Águas minerais e naturais', 'bebida')`);

    // Restaurar produtos
    await connection.execute(`INSERT IGNORE INTO produtos (categoria_id, nome, descricao, preco, estoque, ativo, destaque) VALUES
      (1, 'Creme de cabelo(cachop)', 'Creme modelador para cabelos cacheados', 27.99, 50, TRUE, TRUE),
      (2, 'gel para cabelo', 'Gel fixador extra forte', 15.99, 80, TRUE, TRUE),
      (3, 'Esponja Nudred', 'Esponja twist para cabelos cacheados', 24.99, 30, TRUE, FALSE),
      (3, 'Pata Pata', 'Escova modeladora profissional', 4.99, 25, TRUE, FALSE),
      (4, 'Cerveja lata 350 ml', 'Cerveja pilsen gelada', 8.99, 100, TRUE, TRUE),
      (4, 'Cerveja zero álcool', 'Cerveja sem álcool 350ml', 15.99, 60, TRUE, FALSE),
      (5, 'Refrigerante lata 350 ml', 'Refrigerante cola gelado', 6.99, 120, TRUE, TRUE),
      (6, 'Água mineral 500ml', 'Água mineral natural', 3.50, 150, TRUE, FALSE)`);

    console.log('✅ Dados restaurados com sucesso!');
    await connection.end();
  } catch (error) {
    console.error('Erro:', error.message);
  }
}

restaurar();