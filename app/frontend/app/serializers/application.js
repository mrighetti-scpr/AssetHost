import DS from 'ember-data';

export default DS.RESTSerializer.extend({
  normalizeResponse(store, primaryModelClass, payload, id, requestType){
    if(requestType === 'findAll' || requestType === 'query') {
      return {
        data: payload.map(this._normalizeRecord)
      }
    }
  },
  _normalizeRecord(record){
    const attributes = Object.assign({}, record),
          id         = attributes.id,
          type       = 'asset';
    delete attributes.id;
    return { id, type, attributes };
  }
});

