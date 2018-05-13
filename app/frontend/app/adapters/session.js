import ApplicationAdapter from './application';

export default ApplicationAdapter.extend({
  queryRecord(store, type, query) {
    // Is the same as the built-in queryRecord() except
    // changed to use POST instead of GET.
    const url = this.buildURL(type.modelName, null, null, 'queryRecord', query);

    if (this.sortQueryParams) query = this.sortQueryParams(query);

    return this.ajax(url, 'POST', { data: query });
  }
});

