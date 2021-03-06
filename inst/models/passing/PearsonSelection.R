library(OpenMx)
library(testthat)

m1 <- mxModel(
  'selectionTest',
  mxMatrix('Full', 10, 10, values=rWishart(1, 20, toeplitz((10:1)/10))[,,1],
           dimnames=list(paste0('c',1:10),paste0('c',1:10)), name="m1"),
  mxMatrix('Full', 2, 2, values=diag(2),
           dimnames=list(paste0('c',1:2),paste0('c',1:2)), name="m2"),
  mxMatrix('Full', 10, 1, values=runif(10),
           dimnames=list(paste0('c',1:10),c('v')), name="u1"),
  mxAlgebra(mxPearsonSelCov(m1, m2), name="c1"),
  mxAlgebra(mxPearsonSelMean(m1, m2, u1), name="u2")
)

m1 <- mxRun(m1)

omxCheckCloseEnough(m1$c1$result, mxEval(c1, m1, compute = TRUE), 1e-9)
omxCheckCloseEnough(m1$u2$result, mxEval(u2, m1, compute = TRUE), 1e-9)

# ---- Auto-detect mode

tmp <- m1$m1$values
tmp[1:2,1:2] <- diag(2)

expect_equal(mxPearsonSelCov(tmp, tmp), tmp)
expect_equal(mxPearsonSelMean(tmp, tmp, m1$u1), m1$u1)

m2 <- mxModel(
  'selectionTest',
  mxMatrix('Full', 10, 10, values=c(m1$m1$values), name="m1"),
  mxMatrix('Full', 10, 10, values=tmp, name="m2"),
  m1$u1,
  mxAlgebra(mxPearsonSelCov(m1, m2), name="c1"),
  mxAlgebra(mxPearsonSelMean(m1, m2, u1), name="u2"),
  mxAlgebra(mxPearsonSelCov(m1, m1), name="c2"),
  mxAlgebra(mxPearsonSelMean(m1, m1, u1), name="u3")
)

m2 <- mxRun(m2)

omxCheckCloseEnough(m2$c1$result, m1$c1$result, 1e-9)
omxCheckCloseEnough(m2$u2$result, m1$u2$result, 1e-9)
omxCheckCloseEnough(m2$c2$result, m1$m1$values, 1e-9)
omxCheckCloseEnough(m2$u3$result, m1$u1$values, 1e-9)
omxCheckCloseEnough(m2$c1$result, mxEval(c1, m2, compute = TRUE), 1e-9)
omxCheckCloseEnough(m2$u2$result, mxEval(u2, m2, compute = TRUE), 1e-9)


# ----

m1 <- mxModel(
  'selectionTest',
  mxMatrix('Full', 10, 10, values=rWishart(1, 20, toeplitz((10:1)/10))[,,1],
           dimnames=list(paste0('c',1:10),paste0('c',1:10)), name="m1"),
  mxMatrix('Full', 3, 3, values=diag(3),
           dimnames=list(c('z1','c1','c1'),c('z1','c1','c1')), name="m2"),
  mxAlgebra(mxPearsonSelCov(m1, m2), name="c1")
)

omxCheckError(mxRun(m1), "1:Cannot find row 'z1' in 'selectionTest.m1'
2:Cannot filter row 'c1' in 'selectionTest.m1' more than once")
