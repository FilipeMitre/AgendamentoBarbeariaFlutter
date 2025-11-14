const adminMiddleware = (req, res, next) => {
  // DEBUG: log requester type when accessing admin routes
  console.log('[DEBUG] adminMiddleware: requester userTipo=', req.userTipo, 'userId=', req.userId);

  if (req.userTipo !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Acesso negado. Apenas administradores.'
    });
  }
  next();
};

module.exports = adminMiddleware;
