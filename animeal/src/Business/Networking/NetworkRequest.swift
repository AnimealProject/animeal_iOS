import Services
import AWSPluginsCore
import Amplify

extension Request {
    static func get<M: Model>(_ modelType: M.Type, byId id: String) -> Request<M?> {
        var documentBuilder = ModelBasedGraphQLDocumentBuilder(
            modelSchema: modelType.schema,
            operationType: .query
        )
        documentBuilder.add(decorator: DirectiveNameDecorator(type: .get))
        documentBuilder.add(decorator: ModelIdDecorator(id: id))
        let document = documentBuilder.build()

        return Request<M?>(
            document: document.stringValue,
            variables: document.variables,
            responseType: M?.self,
            decodePath: document.name
        )
    }

    public static func list<M: Model>(
        _ modelType: M.Type,
        where predicate: QueryPredicate? = nil
    ) -> Request<[M]> {
        var documentBuilder = ModelBasedGraphQLDocumentBuilder(
            modelSchema: modelType.schema,
            operationType: .query
        )
        documentBuilder.add(decorator: DirectiveNameDecorator(type: .list))

        if let predicate = predicate {
            documentBuilder.add(
                decorator: FilterDecorator(
                    filter: predicate.graphQLFilter(
                        for: modelType.schema
                    )
                )
            )
        }

        documentBuilder.add(decorator: PaginationDecorator())
        let document = documentBuilder.build()

        return Request<[M]>(
            document: document.stringValue,
            variables: document.variables,
            responseType: [M].self,
            decodePath: document.name + ".items"
        )
    }

    static func mutation<M: Model>(
        of model: M,
        modelSchema: ModelSchema = M.schema,
        where predicate: QueryPredicate? = nil,
        type: RequestMutationType
    ) -> Request<M> {
        var documentBuilder = ModelBasedGraphQLDocumentBuilder(
            modelSchema: modelSchema,
            operationType: .mutation
        )
        documentBuilder.add(decorator: DirectiveNameDecorator(type: type.graphQLMutationType))

        switch type {
        case .create:
            documentBuilder.add(decorator: ModelDecorator(model: model))
        case .delete:
            documentBuilder.add(decorator: ModelIdDecorator(model: model))
            if let predicate = predicate {
                documentBuilder.add(decorator: FilterDecorator(filter: predicate.graphQLFilter(for: modelSchema)))
            }
        case .update:
            documentBuilder.add(decorator: ModelDecorator(model: model))
            if let predicate = predicate {
                documentBuilder.add(decorator: FilterDecorator(filter: predicate.graphQLFilter(for: modelSchema)))
            }
        }
        let document = documentBuilder.build()

        return Request<M>(
            document: document.stringValue,
            variables: document.variables,
            responseType: M.self,
            decodePath: document.name
        )
    }

    public static func create<M: Model>(
        _ model: M,
        modelSchema: ModelSchema
    ) -> Request<M> {
        return mutation(of: model, modelSchema: modelSchema, type: .create)
    }

    public static func create<M: Model>(_ model: M) -> Request<M> {
        return create(model, modelSchema: modelSchema(for: model))
    }

    public static func delete<M: Model>(
        _ model: M,
        where predicate: QueryPredicate? = nil
    ) -> Request<M> {
        return delete(model, modelSchema: modelSchema(for: model), where: predicate)
    }

    public static func delete<M: Model>(
        _ model: M,
        modelSchema: ModelSchema,
        where predicate: QueryPredicate? = nil
    ) -> Request<M> {
        return mutation(of: model, modelSchema: modelSchema, where: predicate, type: .delete)
    }

    private static func modelSchema<M: Model>(for model: M) -> ModelSchema {
        let modelType = ModelRegistry.modelType(from: model.modelName) ?? Swift.type(of: model)
        return modelType.schema
    }
}

extension Request {
    func convertToGraphQLRequest() -> GraphQLRequest<R> {
        return GraphQLRequest<R>(
            apiName: self.apiName,
            document: self.document,
            variables: self.variables,
            responseType: self.responseType,
            decodePath: decodePath
        )
    }
}

enum RequestMutationType {
    case create
    case update
    case delete
}

extension RequestMutationType {
    var graphQLMutationType: GraphQLMutationType {
        switch self {
        case .create:
            return GraphQLMutationType.create
        case .update:
            return GraphQLMutationType.update
        case .delete:
            return GraphQLMutationType.delete
        }
    }
}
