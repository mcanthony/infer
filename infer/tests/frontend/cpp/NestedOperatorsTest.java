/*
* Copyright (c) 2013 - present Facebook, Inc.
* All rights reserved.
*
* This source code is licensed under the BSD style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

package frontend.cpp;

import org.junit.Rule;
import org.junit.Test;

import java.io.IOException;

import utils.DebuggableTemporaryFolder;
import utils.InferException;
import utils.ClangFrontendUtils;

/**
 *  Run C++ frontend on C code and compare it to .dot files produced by C frontend.
 */
public class NestedOperatorsTest {

  String nestedOperatorsBasePath = "infer/tests/codetoanalyze/c/frontend/nestedoperators/";

  @Rule
  public DebuggableTemporaryFolder folder = new DebuggableTemporaryFolder();

  void frontendTest(String fileRelative) throws InterruptedException, IOException, InferException {
    ClangFrontendUtils.createAndCompareCppDotFiles(folder, nestedOperatorsBasePath + fileRelative);
  }


  @Test
  public void whenCaptureRunEnumThenDotFilesAreTheSame()
      throws InterruptedException, IOException, InferException {
    frontendTest("nestedassignment.c");
  }

  @Test
  public void whenCaptureRunUnionThenDotFilesAreTheSame()
      throws InterruptedException, IOException, InferException {
    // .dot file for cpp is different due to autogenerated constructors for union type
    // otherwise cfgs should look the same for C and C++
    frontendTest("union.cpp");
  }

  @Test
  public void whenCaptureRunAssignInConditionThenDotFilesAreTheSame()
      throws InterruptedException, IOException, InferException {
    // .dot file for cpp is slightly different (but semantically equivalent).
    // We need to have different dot file to compare against.
    // assign_in_condition.cpp is in fact pointing to assign_in_condition.c
    frontendTest("assign_in_condition.cpp");
  }

  @Test
  public void whenCaptureRunAssignWithIncrementThenDotFilesAreTheSame()
      throws InterruptedException, IOException, InferException {
    // .dot file differs, but it's semantically equivalent to one produced by
    // C compiler
    frontendTest("assign_with_increment.cpp");
  }
}
