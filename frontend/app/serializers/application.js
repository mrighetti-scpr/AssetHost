import DS from 'ember-data';

export default DS.RESTSerializer.extend({
  normalizeResponse(store, primaryModelClass, payload, id, requestType){
    const type = primaryModelClass.modelName;
    if(requestType === 'findAll' || requestType === 'query') {
      return {
        data: payload.map(record => this._normalizeRecord(record, type) )
      }
    }
    return {
      meta: {},
      data: this._normalizeRecord(payload, type)
    }
  },
  _normalizeRecord(record, type){
    const attributes = Object.assign({}, record),
          id         = attributes.id;
    delete attributes.id;
    return { id, type, attributes };
  }
});

