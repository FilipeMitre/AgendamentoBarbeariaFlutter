const adminMiddleware = (req, res, next) => {
  if (req.userTipo !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Acesso negado. Apenas administradores.'
    });
  }
  next();
};

module.exports = adminMiddleware;
