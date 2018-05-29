import { helper } from '@ember/component/helper';

export function can([user, resource, ability]) {
  if(!user) return false;
  if(user.get('is_admin'))  return true;
  if(!resource || !ability) return false; 
  const permissions = user.get('permissions') || [];
  const permission  = permissions.find(p => p.resource === resource);
  if(!permission)         return false;
  if(!permission.ability) return false;
  if(permission.ability === ability) return true;
  if(ability === 'read' && permission.ability === 'write') return true;
  return false;
}

export default helper(can);

