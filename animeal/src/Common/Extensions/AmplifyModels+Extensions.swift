import Amplify

extension Point: Hashable {
    public static func == (lhs: Point, rhs: Point) -> Bool {
        lhs.type == rhs.type && lhs.coordinates == rhs.coordinates
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(coordinates)
    }
}

extension Location: Hashable {
    public static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.lat == rhs.lat && lhs.lon == rhs.lon
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(lat)
        hasher.combine(lon)
    }
}

extension FeedingPointStatus: Hashable { }

extension Temporal.DateTime: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(foundationDate)
    }
}

extension Category: Hashable {
    public static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
        && lhs.name == rhs.name
        && lhs.icon == rhs.icon
        && lhs.tag == rhs.tag
        && lhs.createdAt == rhs.createdAt
        && lhs.updatedAt == rhs.updatedAt
        && lhs.createdBy == rhs.createdBy
        && lhs.updatedBy == rhs.updatedBy
        && lhs.owner == rhs.owner
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(icon)
        hasher.combine(tag)
        hasher.combine(createdAt)
        hasher.combine(updatedAt)
        hasher.combine(createdBy)
        hasher.combine(updatedBy)
        hasher.combine(owner)
    }
}

extension FeedingPoint: Hashable {
    public static func == (lhs: FeedingPoint, rhs: FeedingPoint) -> Bool {
        lhs.id == rhs.id
        && lhs.name == rhs.name
        && lhs.description == rhs.description
        && lhs.city == rhs.city
        && lhs.street == rhs.street
        && lhs.address == rhs.address
        && lhs.images == rhs.images
        && lhs.point == rhs.point
        && lhs.location == rhs.location
        && lhs.region == rhs.region
        && lhs.neighborhood == rhs.neighborhood
        && lhs.distance == rhs.distance
        && lhs.status == rhs.status
        && lhs.statusUpdatedAt == rhs.statusUpdatedAt
        && lhs.createdAt == rhs.createdAt
        && lhs.updatedAt == rhs.updatedAt
        && lhs.createdBy == rhs.createdBy
        && lhs.updatedBy == rhs.updatedBy
        && lhs.owner == rhs.owner
        && lhs.category == rhs.category
        && lhs.cover == rhs.cover
        && lhs.feedingPointCategoryId == rhs.feedingPointCategoryId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(city)
        hasher.combine(street)
        hasher.combine(address)
        hasher.combine(images)
        hasher.combine(point)
        hasher.combine(location)
        hasher.combine(region)
        hasher.combine(neighborhood)
        hasher.combine(distance)
        hasher.combine(status)
        hasher.combine(statusUpdatedAt)
        hasher.combine(createdAt)
        hasher.combine(updatedAt)
        hasher.combine(createdBy)
        hasher.combine(updatedBy)
        hasher.combine(owner)
        hasher.combine(category)
        hasher.combine(cover)
        hasher.combine(feedingPointCategoryId)
    }
}
