package com.gwtarchetype.dsl.domainmodel.generator;

import net.danieldietrich.xtext.generator.StandaloneGenerator;

import com.google.inject.Injector;
import com.gwtarchetype.dsl.domainmodel.DomainModelStandaloneSetupGenerated;

public class GeneratorFactory {
	
  private GeneratorFactory() {
  }
  
	public static StandaloneGenerator createGenerator() {
    Injector injector = new DomainModelStandaloneSetupGenerated().createInjectorAndDoEMFRegistration();
    StandaloneGenerator generator = injector.getInstance(StandaloneGenerator.class);
    return generator;
	}
	
}
