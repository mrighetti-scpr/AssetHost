import DS from 'ember-data';

export default DS.RESTSerializer.extend({
  normalizeResponse(store, primaryModelClass, payload, id, requestType){
    if(requestType === 'findAll' || requestType === 'query') {
      return {
        data: payload.map(this._normalizeRecord)
      }
    }
    return {
      meta: {},
      data: this._normalizeRecord(payload)
    }
  }
});

