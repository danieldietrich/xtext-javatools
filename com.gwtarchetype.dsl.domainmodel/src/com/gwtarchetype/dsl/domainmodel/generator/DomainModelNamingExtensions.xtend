package com.gwtarchetype.dsl.domainmodel.generator

import com.google.inject.Inject

import com.gwtarchetype.dsl.domainmodel.DomainModelExtensions
import com.gwtarchetype.dsl.domainmodel.domainModel.*

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class DomainModelNamingExtensions {
  
  @Inject extension DomainModelExtensions domainModelExtensions
  
  // -- DSL:Entity
  
  def asEntity(Entity e) {
    e.basePackage+".server.entity."+e.packageName+"."+e.name
  }
  def asDAO(Entity e) {
    e.basePackage+".server.entity."+e.packageName+"."+e.name+"DAO"
  }
  def asDAOLocal(Entity e) {
    e.basePackage+".server.entity."+e.packageName+"."+e.name+"DAOLocal"
  }
  def asEntityProxy(Entity e) {
    e.basePackage+".shared.requestfactory.entity."+e.packageName+"."+e.name+"Proxy"
  }
  def asEntityRequest(Entity e) {
    e.basePackage+".shared.requestfactory.entity."+e.packageName+"."+e.name+"Request"
  }
  
  // -- DSL:Service

  def asService(Service s) {
    s.basePackage+".server.service."+s.packageName+"."+s.name
  }
  def asServiceLocal(Service s) {
    s.basePackage+".server.service."+s.packageName+"."+s.name+"Local"
  }
  def asServiceRequest(Service s) {
    s.basePackage+".shared.requestfactory.service."+s.packageName+"."+s.name+"Request"
  }
  
  // -- DSL:Value
  
  def asValue(Value v) {
    v.basePackage+".server.service."+v.packageName+"."+v.name
  }
  def asValueProxy(Value v) {
    v.basePackage+".shared.requestfactory.service."+v.packageName+"."+v.name+"Proxy"
  }
  
}
