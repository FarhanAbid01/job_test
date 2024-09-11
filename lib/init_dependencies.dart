

import 'package:get_it/get_it.dart';

import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'features/product/data/datasources/image_remote_data_source.dart';
import 'features/product/data/repositories/image_repository_impl.dart';
import 'features/product/domain/repositories/image_repository.dart';
import 'features/product/domain/usecases/get_all_images.dart';
import 'features/product/presentation/bloc/image_bloc.dart';



part 'init_dependencies.main.dart';
