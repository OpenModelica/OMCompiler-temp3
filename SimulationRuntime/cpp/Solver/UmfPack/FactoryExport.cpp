
#include <Core/ModelicaDefine.h>
#include <Core/Modelica.h>
#if defined(OMC_BUILD) && !defined(RUNTIME_STATIC_LINKING)

#include <Solver/UmfPack/UmfPack.h>
#include <Solver/UmfPack/UmfPackSettings.h>

    /* OMC factory */
    using boost::extensions::factory;

BOOST_EXTENSION_TYPE_MAP_FUNCTION {
  types.get<std::map<std::string, factory<ILinearAlgLoopSolver, ILinSolverSettings*> > >()
    ["umfpack"].set<UmfPack>();
  types.get<std::map<std::string, factory<ILinSolverSettings> > >()
    ["umfpackSettings"].set<UmfPackSettings>();
 }
#elif defined(OMC_BUILD) && defined(RUNTIME_STATIC_LINKING)
#include <Solver/UmfPack/UmfPack.h>
#include <Solver/UmfPack/UmfPackSettings.h>

shared_ptr<ILinSolverSettings> createUmfpackSettings()
{
     shared_ptr<ILinSolverSettings> settings = shared_ptr<ILinSolverSettings>(new UmfPackSettings());
     return settings;
}

shared_ptr<ILinearAlgLoopSolver> createUmfpackSolver(shared_ptr<ILinSolverSettings> solver_settings)
{
   shared_ptr<ILinearAlgLoopSolver> solver = shared_ptr<ILinearAlgLoopSolver>(new UmfPack(solver_settings.get()));
   return solver;
}

#else
error "operating system not supported"
#endif



