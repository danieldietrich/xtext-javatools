package com.gwtarchetype.dsl.domainmodel.generator

import com.google.inject.Inject

import com.gwtarchetype.dsl.domainmodel.DomainModelExtensions
import com.gwtarchetype.dsl.domainmodel.domainModel.*

import net.danieldietrich.xtext.xtend2.javasupport.JavaExtensions
import net.danieldietrich.xtext.xtend2.javasupport.imports.ImportExtensions
import net.danieldietrich.xtext.xtend2.javasupport.imports.ImportManager
import net.danieldietrich.xtext.xtend2.javasupport.types.TypeExtensions

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class _EntityGenerator {
  
  // dsl specific extensions 
  @Inject extension DomainModelExtensions dmainModelExtensions
  
  // naming
  @Inject extension DomainModelNamingExtensions domainModelNamingExtensions
  
  // java support
  @Inject extension ImportExtensions importExtensions
  @Inject extension JavaExtensions javaExtensions
  @Inject extension TypeExtensions typeExtensions

  /**
   * Compile DomainModel Entity -> Java JPA Entity
   * @tags #Entity
   */ 
  def compileEntity(Entity entity, ImportManager im) '''
    «val queryOps = entity.features.filter(typeof(OperationWithQuery)).filter(op | op.query != null)»
    «IF queryOps.size > 0»
    @«"javax.persistence.NamedQueries".shortName(im)»({
      «FOR op : queryOps SEPARATOR ","»
      @«"javax.persistence.NamedQuery".shortName(im)»(name = "«entity.name».«op.name»", query = «op.query»)
      «ENDFOR»
    })
    «ENDIF»
    @«"javax.persistence.Entity".shortName(im)»
    public class «entity.asEntity.simpleName»«IF entity.superType != null» extends «entity.superType.shortName(im)»«ENDIF» implements «"com.fysell.server.entity.Entity".shortName(im)» {
    
      @«"javax.persistence.Id".shortName(im)»
      @«"javax.persistence.GeneratedValue".shortName(im)»(strategy = «"javax.persistence.GenerationType".shortName(im)».AUTO)
      private Long id;

      @«"javax.persistence.Version".shortName(im)»
      private Integer version;
    
      «FOR attr : entity.features.filter(typeof(Property))»
      private «attr.type.shortName(im)» «attr.name.asAttribute»;
      «ENDFOR»
    
      public Long getId() {
        return this.id;
      }
      public void setId(Long id) {
        this.id = id;
      }

      public Integer getVersion() {
        return this.version;
      }
      public void setVersion(Integer version) {
        this.version = version;
      }
      
      «FOR attr : entity.features.filter(typeof(Property)) SEPARATOR "\n"»
      public «attr.type.shortName(im)» «attr.name.asGetter»() {
        return «attr.name.asAttribute»;
      }
      public void «attr.name.asSetter»(«attr.type.shortName(im)» «attr.name.asAttribute») {
        this.«attr.name.asAttribute» = «attr.name.asAttribute»;
      }
      «ENDFOR»
    }
  '''
  
  /**
   * Compile DomainModel Entity -> Java @Stateless DAO
   * @tags #DAO
   */ 
  def compileDAO(Entity entity, ImportManager im) '''
    @«"javax.ejb.Stateless".shortName(im)»
    abstract class «entity.asDAO.simpleName» implements «entity.asDAOLocal.shortName(im)» {

      @«"javax.persistence.PersistenceContext".shortName(im)»(unitName = "punit")
      protected «"javax.persistence.EntityManager".shortName(im)» em;

      @Override
      public «entity.asEntity.shortName(im)» find(Long id) {
        return em.find(«entity.asEntity.shortName(im)».class, id);
      }

      @Override
      public «entity.asEntity.shortName(im)» merge(«entity.asEntity.shortName(im)» entity) {
        return em.merge(entity);
      }

      @Override
      public void persist(«entity.asEntity.shortName(im)» entity) {
        em.persist(entity);
      }

      @Override
      public void refresh(«entity.asEntity.shortName(im)» entity) {
        em.refresh(entity);
      }

      @Override
      public void remove(«entity.asEntity.shortName(im)» entity) {
        Object attached = em.find(entity.getClass(), entity.getId());
        em.remove(attached);
      }

      «FOR op : entity.features.filter(typeof(OperationWithQuery)).filter(op | op.query != null) SEPARATOR "\n"»
        «IF op.isPublic»@Override«ENDIF»
        «op.modifiers»«op.type.shortName(im)» «op.name»(«op.params(im)») {
        /* PROTECTED REGION ID(«entity.name + "." + op.name») START */
          «IF !op.type.isVoid»return «ENDIF»em.createNamedQuery("«entity.name».«op.name»"«IF !op.type.isVoid», «op.queryReturnElementType(im)»«ENDIF»)
            «FOR param : op.params SEPARATOR "\n"»
            .setParameter("«param.name»", «param.name.asParameter»)
            «ENDFOR»
            «op.executeQuery(im)»;
        }
        /* PROTECTED REGION END */
      «ENDFOR»
      
      «FOR op : entity.features.filter(typeof(OperationWithQuery)).filter(op | op.query == null && !op.isPublic) SEPARATOR "\n"»
        «op.modifiers»abstract «op.type.shortName(im)» «op.name»(«op.params(im)»);
      «ENDFOR»
    }
  '''
  
  /**
   * Compile DomainModel Entity -> Java @Local DAO Interface
   * @tags #DAOLocal
   */ 
  def compileDAOLocal(Entity entity, ImportManager im) '''
    @«"javax.ejb.Local".shortName(im)»
    public interface «entity.asDAOLocal.simpleName» {

      «entity.asEntity.shortName(im)» find(Long id);
      «entity.asEntity.shortName(im)» merge(«entity.asEntity.shortName(im)» entity);
      void persist(«entity.asEntity.shortName(im)» entity);
      void refresh(«entity.asEntity.shortName(im)» entity);
      void remove(«entity.asEntity.shortName(im)» entity);
      
      «FOR op : entity.features.filter(typeof(OperationWithQuery)).filter(op | op.isPublic)»
      «IF op.type.isVoid»int«ELSE»«op.type.shortName(im)»«ENDIF» «op.name»(«op.params(im)»);
      «ENDFOR»
    }
  '''
  
  /**
   * Compile DomainModel Entity -> Java GWT RequestFactory EntityProxy
   * @tags #EntityProxy
   */
  def compileEntityProxy(Entity entity, ImportManager im) '''
    @«"com.google.web.bindery.requestfactory.shared.ProxyFor".shortName(im)»(value = «entity.asEntity.shortName(im)».class, locator = «"com.gwtarchetype.server.requestfactory.EntityLocator".shortName(im)».class)
    public interface «entity.asEntityProxy.simpleName» extends «"com.google.web.bindery.requestfactory.shared.EntityProxy".shortName(im)» {
    
      @Override
      «"com.google.web.bindery.requestfactory.shared.EntityProxyId".shortName(im)»<«entity.asEntityProxy.simpleName»> stableId();
    
      «FOR attr : entity.features.filter(typeof(Property)) SEPARATOR "\n"»
      «attr.type.shortName(im)» «attr.name.asGetter»();
      void «attr.name.asSetter»(«attr.type.shortName(im)» «attr.name.asAttribute»);
      «ENDFOR»
    }
  '''
  
  /**
   * Compile DomainModel Entity -> Java GWT RequestFactory Request
   * @tags #Request
   */
  def compileEntityRequest(Entity entity, ImportManager im) '''
    @«"com.google.web.bindery.requestfactory.shared.Service".shortName(im)»(value = «entity.asDAOLocal.shortName(im)».class, locator = «"com.gwtarchetype.server.requestfactory.EJBServiceLocator".shortName(im)».class)
    public interface «entity.asEntityRequest.simpleName» extends «"com.google.web.bindery.requestfactory.shared.RequestContext".shortName(im)» {

      «"com.google.web.bindery.requestfactory.shared.Request".shortName(im)»<«entity.asEntityProxy.shortName(im)»> find(Long id);
      «"com.google.web.bindery.requestfactory.shared.Request".shortName(im)»<«entity.asEntityProxy.shortName(im)»> merge(«entity.asEntityProxy.shortName(im)» registration);
      «"com.google.web.bindery.requestfactory.shared.Request".shortName(im)»<Void> persist(«entity.asEntityProxy.shortName(im)» registration);
      «"com.google.web.bindery.requestfactory.shared.Request".shortName(im)»<Void> remove(«entity.asEntityProxy.shortName(im)» registration);

      «FOR op : entity.features.filter(typeof(OperationWithQuery)).filter(op | op.isPublic)»
      «"com.google.web.bindery.requestfactory.shared.Request".shortName(im)»<«op.type.shortName(im).box»> «op.name»(«op.params(im)»);
      «ENDFOR»
    }
  '''
  
  /**
   * Method arguments
   */
  /*private*/ def params(OperationWithQuery op, ImportManager im) '''
    «FOR arg : op.params SEPARATOR ", "»«arg.parameterType.shortName(im)» «arg.name.asParameter»«ENDFOR»'''

  /**
   * The type of an element of the query result.
   * If it is a single result, it is the type of the single element.
   * If it is a result list, it is the type of the list elements.
   */
  /*private*/ def queryReturnElementType(OperationWithQuery op, ImportManager im) {
    if (op.type.isVoid) {
      throw new IllegalArgumentException("void is not a valid query result element type")
    } else if (op.type.isNumber) {
      "Number.class"
    } else if (op.type.isList) {
      op.type.arguments.head.shortName(im) + ".class"
    } else {
      op.type.shortName(im) + ".class"
    }
  }
  
  /**
   * The execution method depends on the return type of the operation.
   */
  /*private*/ def executeQuery(OperationWithQuery op, ImportManager im) {
    if (op.type.isVoid) {
      ".executeUpdate()"
    } else if (op.type.isNumber) {
      ".getSingleResult()." + op.type.simpleName + "Value()"
    } else if (op.type.isList) {
      ".getResultList()"
    } else {
      ".getSingleResult()"
    }
  }
  
  /**
   * Operation modifiers.
   */
  /*private*/ def modifiers(OperationWithQuery op) {
    if (op.isPublic) {
      "public "
    } else if (op.isProtected) {
      "protected "
    } else if (op.isDefaultVisibility) {
      ""
    } else {
      throw new IllegalArgumentException("unknown visibility: " + op.visibility);
    }
  }

}
