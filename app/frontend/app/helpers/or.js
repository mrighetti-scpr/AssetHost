import { helper } from '@ember/component/helper';

export function or([value, customDefault]) {
  return value || (customDefault || '');
}

export default helper(or);

