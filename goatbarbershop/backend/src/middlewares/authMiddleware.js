const { verifyToken } = require('../utils/helpers');

const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      console.log('[DEBUG] authMiddleware: Authorization header missing');
      return res.status(401).json({
        success: false,
        message: 'Token não fornecido'
      });
    }

    const token = authHeader.split(' ')[1];
    const decoded = verifyToken(token);

    // DEBUG: log decoded token minimal info
    console.log('[DEBUG] authMiddleware: token decoded=', decoded ? { id: decoded.id, tipo: decoded.tipo } : null);

    if (!decoded) {
      return res.status(401).json({
        success: false,
        message: 'Token inválido ou expirado'
      });
    }

    req.userId = decoded.id;
    req.userTipo = decoded.tipo;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Erro na autenticação'
    });
  }
};

module.exports = authMiddleware;
