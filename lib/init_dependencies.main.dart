



part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
  _initImageFeature();
}

Future<void> _initCore() async {
  // Register http.Client as a singleton for making HTTP requests
  serviceLocator.registerLazySingleton<http.Client>(() => http.Client());

}

void _initImageFeature() {
  final internetConnection = InternetConnection();
  // Datasource
  serviceLocator
    ..registerFactory<ImageRemoteDataSource>(
          () => ImageRemoteDataSourceImpl(
            client:  serviceLocator<http.Client>(), // Inject http.Client
        apiKey:'45913900-82f67475310bafec37eb8ec2f', // Set your Pixabay API key here
      ),
    )

  // Repository
    ..registerFactory<ImageRepository>(
          () => ImageRepositoryImpl(
        remoteDataSource: serviceLocator<ImageRemoteDataSource>(),
      ),
    )
  // Use cases
    ..registerFactory(
          () => GetAllImages(serviceLocator<ImageRepository>()),
    )

  // Bloc
    ..registerLazySingleton(
          () => ImageBloc(
            internetConnection: internetConnection,
        getAllImages: serviceLocator<GetAllImages>(),
      ),
    );
}
