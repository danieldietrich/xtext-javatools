package net.danieldietrich.xtext.xbase.jvmmodel.impl;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

import net.danieldietrich.xtext.xbase.jvmmodel.InferredJvmType;
import net.danieldietrich.xtext.xbase.jvmmodel.InferredJvmTypeFactory;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.common.types.JvmGenericType;
import org.eclipse.xtext.common.types.TypesFactory;

import com.google.inject.Inject;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class InferredJvmTypeFactoryImpl implements InferredJvmTypeFactory {

  private static Method METHOD_getModelElement_void;
  private final TypesFactory typesFactory;
  
  @Inject
  InferredJvmTypeFactoryImpl(TypesFactory typesFactory) {
    this.typesFactory = typesFactory;
    if (METHOD_getModelElement_void == null) {
      try {
        METHOD_getModelElement_void = InferredJvmType.class.getMethod("getModelElement", new Class<?>[] {});
      } catch(NoSuchMethodException x) {
        throw new RuntimeException("Method " + InferredJvmType.class.getName() + "#" + "getModelElement() not found", x);
      }
    }
  }
  
  @SuppressWarnings("unchecked")
  public <T extends EObject> InferredJvmType<T> createInferredJvmType(final T modelElement, String packageName, String simpleName) {

    final JvmGenericType type = typesFactory.createJvmGenericType();
    type.setPackageName(packageName);
    type.setSimpleName(simpleName);
      
    return (InferredJvmType<T>) Proxy.newProxyInstance(
        getClass().getClassLoader(),
        new Class<?>[] { InferredJvmType.class },
        new InvocationHandler() {
          @Override
          public Object invoke(Object o, Method m, Object[] args) throws Throwable {
            if (METHOD_getModelElement_void.equals(m)) {
              return modelElement;
            } else {
              return m.invoke(type, args);
            }
          }
        });
  }
  
}
