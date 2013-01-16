package net.danieldietrich.xtext.xbase.jvmmodel;

import org.eclipse.emf.ecore.EObject;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface InferredJvmTypeFactory {

  <T extends EObject> InferredJvmType<T> createInferredJvmType(final T modelElement, String packageName, String simpleName);
  
}
