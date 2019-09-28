

mop = testmop('zdt1',30);
mop = testmop('kno1');
[pareto,funccount] = moead( mop, 'popsize', 50, 'niche', 20, 'iteration', 100, 'method', 'te');

%pareto = moead( mop, 'popsize', 100, 'niche', 20, 'iteration', 200, 'method', 'ws');

