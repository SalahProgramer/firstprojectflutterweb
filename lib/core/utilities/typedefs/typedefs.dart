import 'package:dartz/dartz.dart';

import 'failure.dart';

typedef EitherResponse<T> = Future<Either<Failure, T>>;
typedef Json = Map<String, dynamic>?;
